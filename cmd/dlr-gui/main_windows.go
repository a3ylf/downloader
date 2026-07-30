//go:build windows

package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"syscall"
	"unsafe"
)

var version = "0.2.0-dev"

const (
	windowWidth  = 720
	windowHeight = 560

	idURL      = 101
	idFormat   = 102
	idQuality  = 103
	idOutput   = 104
	idBrowse   = 105
	idDownload = 106
	idOpen     = 107
	idLog      = 108

	wmCreate       = 0x0001
	wmDestroy      = 0x0002
	wmClose        = 0x0010
	wmCommand      = 0x0111
	wmSetFont      = 0x0030
	wmSetText      = 0x000C
	wmApp          = 0x8000
	wmDownloadDone = wmApp + 1

	wsOverlappedWindow = 0x00CF0000
	wsChild            = 0x40000000
	wsVisible          = 0x10000000
	wsTabStop          = 0x00010000
	wsVScroll          = 0x00200000
	wsExClientEdge     = 0x00000200

	esAutoHScroll = 0x0080
	esMultiline   = 0x0004
	esAutoVScroll = 0x0040
	esReadOnly    = 0x0800

	cbsDropdownList = 0x0003
	cbnSelChange    = 1
	bsPushButton    = 0x00000000

	cbAddString = 0x0143
	cbGetCurSel = 0x0147
	cbSetCurSel = 0x014E

	emSetSel     = 0x00B1
	emReplaceSel = 0x00C2

	colorWindow    = 5
	defaultGUIFont = 17
	idcArrow       = 32512
	idiApplication = 32512
	swShow         = 5
	swShowNormal   = 1

	bifReturnOnlyFSDirs = 0x0001
	bifNewDialogStyle   = 0x0040
)

var (
	user32   = syscall.NewLazyDLL("user32.dll")
	kernel32 = syscall.NewLazyDLL("kernel32.dll")
	gdi32    = syscall.NewLazyDLL("gdi32.dll")
	shell32  = syscall.NewLazyDLL("shell32.dll")
	ole32    = syscall.NewLazyDLL("ole32.dll")

	procRegisterClassEx     = user32.NewProc("RegisterClassExW")
	procCreateWindowEx      = user32.NewProc("CreateWindowExW")
	procDefWindowProc       = user32.NewProc("DefWindowProcW")
	procDestroyWindow       = user32.NewProc("DestroyWindow")
	procGetMessage          = user32.NewProc("GetMessageW")
	procTranslateMessage    = user32.NewProc("TranslateMessage")
	procDispatchMessage     = user32.NewProc("DispatchMessageW")
	procIsDialogMessage     = user32.NewProc("IsDialogMessageW")
	procPostQuitMessage     = user32.NewProc("PostQuitMessage")
	procPostMessage         = user32.NewProc("PostMessageW")
	procSendMessage         = user32.NewProc("SendMessageW")
	procSetWindowText       = user32.NewProc("SetWindowTextW")
	procGetWindowText       = user32.NewProc("GetWindowTextW")
	procGetWindowTextLength = user32.NewProc("GetWindowTextLengthW")
	procEnableWindow        = user32.NewProc("EnableWindow")
	procShowWindow          = user32.NewProc("ShowWindow")
	procUpdateWindow        = user32.NewProc("UpdateWindow")
	procLoadCursor          = user32.NewProc("LoadCursorW")
	procLoadIcon            = user32.NewProc("LoadIconW")
	procMessageBox          = user32.NewProc("MessageBoxW")
	procSetDPIAware         = user32.NewProc("SetProcessDpiAwarenessContext")

	procGetModuleHandle = kernel32.NewProc("GetModuleHandleW")
	procGetStockObject  = gdi32.NewProc("GetStockObject")

	procBrowseForFolder = shell32.NewProc("SHBrowseForFolderW")
	procGetPathFromID   = shell32.NewProc("SHGetPathFromIDListW")
	procShellExecute    = shell32.NewProc("ShellExecuteW")

	procCoInitialize = ole32.NewProc("CoInitializeEx")
	procCoUninit     = ole32.NewProc("CoUninitialize")
	procCoTaskFree   = ole32.NewProc("CoTaskMemFree")

	mainWindow    uintptr
	urlInput      uintptr
	formatCombo   uintptr
	qualityCombo  uintptr
	outputInput   uintptr
	browseButton  uintptr
	downloadBtn   uintptr
	openButton    uintptr
	statusLabel   uintptr
	logInput      uintptr
	logWriteMutex sync.Mutex
)

type point struct {
	x int32
	y int32
}

type message struct {
	hwnd    uintptr
	message uint32
	wParam  uintptr
	lParam  uintptr
	time    uint32
	pt      point
	private uint32
}

type windowClassEx struct {
	size       uint32
	style      uint32
	wndProc    uintptr
	clsExtra   int32
	wndExtra   int32
	instance   uintptr
	icon       uintptr
	cursor     uintptr
	background uintptr
	menuName   *uint16
	className  *uint16
	iconSmall  uintptr
}

type browseInfo struct {
	owner       uintptr
	root        uintptr
	displayName *uint16
	title       *uint16
	flags       uint32
	callback    uintptr
	param       uintptr
	image       int32
}

func main() {
	runtime.LockOSThread()

	procSetDPIAware.Call(^uintptr(3)) // DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
	procCoInitialize.Call(0, 0x2)     // COINIT_APARTMENTTHREADED
	defer procCoUninit.Call()

	instance, _, _ := procGetModuleHandle.Call(0)
	className := utf16("DLRDesktopWindow")
	title := utf16("DLR Downloader " + version)

	icon, _, _ := procLoadIcon.Call(0, idiApplication)
	cursor, _, _ := procLoadCursor.Call(0, idcArrow)
	class := windowClassEx{
		size:       uint32(unsafe.Sizeof(windowClassEx{})),
		wndProc:    syscall.NewCallback(windowProc),
		instance:   instance,
		icon:       icon,
		cursor:     cursor,
		background: colorWindow + 1,
		className:  className,
		iconSmall:  icon,
	}
	if registered, _, err := procRegisterClassEx.Call(uintptr(unsafe.Pointer(&class))); registered == 0 {
		fatalBox("Could not register the application window: " + err.Error())
		return
	}

	hwnd, _, err := procCreateWindowEx.Call(
		0,
		uintptr(unsafe.Pointer(className)),
		uintptr(unsafe.Pointer(title)),
		wsOverlappedWindow,
		0x80000000, 0x80000000,
		windowWidth, windowHeight,
		0, 0, instance, 0,
	)
	if hwnd == 0 {
		fatalBox("Could not create the application window: " + err.Error())
		return
	}
	mainWindow = hwnd

	procShowWindow.Call(hwnd, swShow)
	procUpdateWindow.Call(hwnd)

	var msg message
	for {
		result, _, _ := procGetMessage.Call(uintptr(unsafe.Pointer(&msg)), 0, 0, 0)
		if result == 0 || int32(result) == -1 {
			break
		}
		handled, _, _ := procIsDialogMessage.Call(hwnd, uintptr(unsafe.Pointer(&msg)))
		if handled == 0 {
			procTranslateMessage.Call(uintptr(unsafe.Pointer(&msg)))
			procDispatchMessage.Call(uintptr(unsafe.Pointer(&msg)))
		}
	}
}

func windowProc(hwnd uintptr, msg uint32, wParam, lParam uintptr) uintptr {
	switch msg {
	case wmCreate:
		createUI(hwnd)
		return 0
	case wmCommand:
		id := int(wParam & 0xffff)
		notification := int((wParam >> 16) & 0xffff)
		switch id {
		case idBrowse:
			if folder := browseForFolder(hwnd); folder != "" {
				setText(outputInput, folder)
			}
		case idDownload:
			startDownload()
		case idOpen:
			openOutputFolder()
		case idFormat:
			if notification == cbnSelChange {
				updateQualityState()
			}
		}
		return 0
	case wmDownloadDone:
		setDownloading(false)
		if wParam == 0 {
			setText(statusLabel, "Download completed.")
			appendLog("\r\nDone. Your file is in " + getText(outputInput) + "\r\n")
		} else {
			setText(statusLabel, "Download failed. See the details below.")
		}
		return 0
	case wmClose:
		procDestroyWindow.Call(hwnd)
		return 0
	case wmDestroy:
		procPostQuitMessage.Call(0)
		return 0
	default:
		result, _, _ := procDefWindowProc.Call(hwnd, uintptr(msg), wParam, lParam)
		return result
	}
}

func createUI(parent uintptr) {
	font, _, _ := procGetStockObject.Call(defaultGUIFont)

	createControl("STATIC", "Video or post link", wsChild|wsVisible, 20, 18, 660, 20, 0, parent, font)
	urlInput = createControl("EDIT", "", wsChild|wsVisible|wsTabStop|esAutoHScroll, 20, 40, 660, 28, idURL, parent, font)

	createControl("STATIC", "Download as", wsChild|wsVisible, 20, 82, 200, 20, 0, parent, font)
	formatCombo = createControl("COMBOBOX", "", wsChild|wsVisible|wsTabStop|cbsDropdownList, 20, 104, 210, 150, idFormat, parent, font)
	addComboItems(formatCombo, []string{"Video (MP4)", "Audio (MP3)"})

	createControl("STATIC", "Maximum quality", wsChild|wsVisible, 250, 82, 200, 20, 0, parent, font)
	qualityCombo = createControl("COMBOBOX", "", wsChild|wsVisible|wsTabStop|cbsDropdownList, 250, 104, 210, 150, idQuality, parent, font)
	addComboItems(qualityCombo, []string{"Best available", "1080p", "720p", "480p"})

	createControl("STATIC", "Save to", wsChild|wsVisible, 20, 145, 200, 20, 0, parent, font)
	outputInput = createControl("EDIT", defaultOutputFolder(), wsChild|wsVisible|wsTabStop|esAutoHScroll, 20, 167, 550, 28, idOutput, parent, font)
	browseButton = createControl("BUTTON", "Browse...", wsChild|wsVisible|wsTabStop|bsPushButton, 580, 166, 100, 30, idBrowse, parent, font)

	downloadBtn = createControl("BUTTON", "Download", wsChild|wsVisible|wsTabStop|bsPushButton, 20, 215, 140, 36, idDownload, parent, font)
	openButton = createControl("BUTTON", "Open folder", wsChild|wsVisible|wsTabStop|bsPushButton, 170, 215, 140, 36, idOpen, parent, font)
	statusLabel = createControl("STATIC", "Ready.", wsChild|wsVisible, 330, 224, 350, 22, 0, parent, font)

	logInput = createControl("EDIT", "Paste a link, choose the options, and click Download.\r\n",
		wsChild|wsVisible|wsVScroll|esMultiline|esAutoVScroll|esReadOnly,
		20, 270, 660, 230, idLog, parent, font)
}

func createControl(class, text string, style uintptr, x, y, width, height, id int, parent, font uintptr) uintptr {
	exStyle := uintptr(wsExClientEdge)
	if class == "STATIC" || class == "BUTTON" || class == "COMBOBOX" {
		exStyle = 0
	}
	hwnd, _, _ := procCreateWindowEx.Call(
		exStyle,
		uintptr(unsafe.Pointer(utf16(class))),
		uintptr(unsafe.Pointer(utf16(text))),
		style,
		uintptr(x), uintptr(y), uintptr(width), uintptr(height),
		parent, uintptr(id), 0, 0,
	)
	if hwnd != 0 {
		procSendMessage.Call(hwnd, wmSetFont, font, 1)
	}
	return hwnd
}

func addComboItems(combo uintptr, items []string) {
	for _, item := range items {
		value := utf16(item)
		procSendMessage.Call(combo, cbAddString, 0, uintptr(unsafe.Pointer(value)))
	}
	procSendMessage.Call(combo, cbSetCurSel, 0, 0)
}

func startDownload() {
	link := strings.TrimSpace(getText(urlInput))
	output := strings.TrimSpace(getText(outputInput))
	if link == "" {
		messageBox(mainWindow, "Paste a video or post link first.", "Missing link")
		return
	}
	if output == "" {
		messageBox(mainWindow, "Choose an output folder first.", "Missing folder")
		return
	}

	backend, err := backendPath()
	if err != nil {
		messageBox(mainWindow, err.Error(), "DLR backend not found")
		return
	}

	format, _, _ := procSendMessage.Call(formatCombo, cbGetCurSel, 0, 0)
	quality, _, _ := procSendMessage.Call(qualityCombo, cbGetCurSel, 0, 0)
	args := downloadArgs(int(format), int(quality), output, link)

	setDownloading(true)
	setText(statusLabel, "Downloading...")
	setText(logInput, "Starting download...\r\n")

	go func() {
		cmd := exec.Command(backend, args...)
		cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
		writer := &controlWriter{}
		cmd.Stdout = writer
		cmd.Stderr = writer

		if err := cmd.Run(); err != nil {
			appendLog("\r\nDownload failed: " + err.Error() + "\r\n")
			procPostMessage.Call(mainWindow, wmDownloadDone, 1, 0)
			return
		}
		procPostMessage.Call(mainWindow, wmDownloadDone, 0, 0)
	}()
}

func setDownloading(active bool) {
	enabled := uintptr(1)
	if active {
		enabled = 0
	}
	procEnableWindow.Call(urlInput, enabled)
	procEnableWindow.Call(formatCombo, enabled)
	procEnableWindow.Call(outputInput, enabled)
	procEnableWindow.Call(browseButton, enabled)
	procEnableWindow.Call(downloadBtn, enabled)
	if active {
		procEnableWindow.Call(qualityCombo, 0)
	} else {
		updateQualityState()
	}
}

func updateQualityState() {
	format, _, _ := procSendMessage.Call(formatCombo, cbGetCurSel, 0, 0)
	if format == 0 {
		procEnableWindow.Call(qualityCombo, 1)
	} else {
		procEnableWindow.Call(qualityCombo, 0)
	}
}

func backendPath() (string, error) {
	executable, err := os.Executable()
	if err == nil {
		sibling := filepath.Join(filepath.Dir(executable), "dlr.exe")
		if info, statErr := os.Stat(sibling); statErr == nil && !info.IsDir() {
			return sibling, nil
		}
	}
	if found, lookErr := exec.LookPath("dlr.exe"); lookErr == nil {
		return found, nil
	}
	return "", fmt.Errorf("dlr.exe must be in the same folder as dlr-gui.exe. Extract the complete Windows portable ZIP before running the app")
}

func openOutputFolder() {
	folder := strings.TrimSpace(getText(outputInput))
	if folder == "" {
		return
	}
	result, _, _ := procShellExecute.Call(
		mainWindow,
		uintptr(unsafe.Pointer(utf16("open"))),
		uintptr(unsafe.Pointer(utf16(folder))),
		0, 0, swShowNormal,
	)
	if result <= 32 {
		messageBox(mainWindow, "Windows could not open that folder.", "Open folder")
	}
}

func browseForFolder(owner uintptr) string {
	var display [260]uint16
	info := browseInfo{
		owner:       owner,
		displayName: &display[0],
		title:       utf16("Choose where downloaded files will be saved"),
		flags:       bifReturnOnlyFSDirs | bifNewDialogStyle,
	}
	itemID, _, _ := procBrowseForFolder.Call(uintptr(unsafe.Pointer(&info)))
	if itemID == 0 {
		return ""
	}
	defer procCoTaskFree.Call(itemID)

	var path [260]uint16
	ok, _, _ := procGetPathFromID.Call(itemID, uintptr(unsafe.Pointer(&path[0])))
	if ok == 0 {
		return ""
	}
	return syscall.UTF16ToString(path[:])
}

func defaultOutputFolder() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return "."
	}
	return filepath.Join(home, "Downloads")
}

type controlWriter struct{}

func (writer *controlWriter) Write(data []byte) (int, error) {
	appendLog(string(data))
	return len(data), nil
}

func appendLog(text string) {
	logWriteMutex.Lock()
	defer logWriteMutex.Unlock()

	text = strings.ReplaceAll(text, "\r\n", "\n")
	text = strings.ReplaceAll(text, "\n", "\r\n")
	value := utf16(text)
	procSendMessage.Call(logInput, emSetSel, ^uintptr(0), ^uintptr(0))
	procSendMessage.Call(logInput, emReplaceSel, 0, uintptr(unsafe.Pointer(value)))
}

func setText(hwnd uintptr, text string) {
	value := utf16(text)
	procSetWindowText.Call(hwnd, uintptr(unsafe.Pointer(value)))
}

func getText(hwnd uintptr) string {
	length, _, _ := procGetWindowTextLength.Call(hwnd)
	buffer := make([]uint16, length+1)
	procGetWindowText.Call(hwnd, uintptr(unsafe.Pointer(&buffer[0])), length+1)
	return syscall.UTF16ToString(buffer)
}

func messageBox(owner uintptr, text, title string) {
	procMessageBox.Call(
		owner,
		uintptr(unsafe.Pointer(utf16(text))),
		uintptr(unsafe.Pointer(utf16(title))),
		0x30,
	)
}

func fatalBox(text string) {
	messageBox(0, text, "DLR Downloader")
}

func utf16(value string) *uint16 {
	result, err := syscall.UTF16PtrFromString(value)
	if err != nil {
		panic(err)
	}
	return result
}
