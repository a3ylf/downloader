package main

import (
	_ "embed"
	"encoding/base64"
	"strings"
)

//go:embed ui_windows.ps1
var uiScriptTemplate string

//go:embed ui_spectrum.xaml
var uiXAML string

//go:embed ui_icon.png
var uiIcon []byte

var uiScript = buildUIScript()

func buildUIScript() string {
	script := strings.Replace(
		uiScriptTemplate,
		"__DLR_EMBEDDED_XAML__",
		base64.StdEncoding.EncodeToString([]byte(uiXAML)),
		1,
	)
	return strings.Replace(
		script,
		"__DLR_EMBEDDED_ICON__",
		base64.StdEncoding.EncodeToString(uiIcon),
		1,
	)
}
