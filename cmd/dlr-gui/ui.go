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

var uiScript = strings.Replace(
	uiScriptTemplate,
	"__DLR_EMBEDDED_XAML__",
	base64.StdEncoding.EncodeToString([]byte(uiXAML)),
	1,
)
