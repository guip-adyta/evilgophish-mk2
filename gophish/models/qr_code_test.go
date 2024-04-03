package models

import (
	"fmt"

	"gopkg.in/check.v1"
)

func (s *ModelsSuite) TestGenQR(ch *check.C) {
	qr, err := generateAsciiQRCode("https://google.com")
	ch.Assert(err, check.Equals, nil)
	fmt.Printf("QR CODE:\n%v\n", qr)
}
