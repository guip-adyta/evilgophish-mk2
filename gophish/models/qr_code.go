package models

import (
	"bytes"
	"fmt"
	"regexp"
	"strings"

	"github.com/mdp/qrterminal/v3"
)

type AsciiQRCodeWriter struct {
	Buffer bytes.Buffer
}

func (w *AsciiQRCodeWriter) Write(p []byte) (n int, err error) {
	return w.Buffer.Write(p)
}

func generateAsciiQRCode(content string, stringSize string) (string, error) {
	if !strings.HasSuffix(stringSize, "px") {
		stringSize += "px"
	}
	writer := &AsciiQRCodeWriter{}
	config := qrterminal.Config{
		Level:          qrterminal.M,
		Writer:         writer,
		HalfBlocks:     true,
		BlackChar:      "&#9608;",
		BlackWhiteChar: "&#9600;",
		WhiteChar:      "&nbsp;",
		WhiteBlackChar: "&#9604;",
		QuietZone:      1,
	}
	qrterminal.GenerateWithConfig(content, config)
	re := regexp.MustCompile(`\n`)
	stdrQr := re.ReplaceAllString(writer.Buffer.String(), "<br>\n")
	qrPack := fmt.Sprintf("<p style=\"font-family:monospace;font-size:%s;line-height:%s\">\n%s</p>", stringSize, stringSize, stdrQr)
	return qrPack, nil
}
