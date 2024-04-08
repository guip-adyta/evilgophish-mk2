package models

import (
	"fmt"

	check "gopkg.in/check.v1"
)

type mockTemplateContext struct {
	URL         string
	FromAddress string
}

func (m mockTemplateContext) getFromAddress() string {
	return m.FromAddress
}

func (m mockTemplateContext) getBaseURL() string {
	return m.URL
}

func (m mockTemplateContext) getQRSize() string {
	return "15px"
}

func (s *ModelsSuite) TestNewTemplateContext(c *check.C) {
	r := Result{
		BaseRecipient: BaseRecipient{
			FirstName: "Foo",
			LastName:  "Bar",
			Email:     "foo@bar.com",
		},
		RId: "1234567",
	}
	ctx := mockTemplateContext{
		URL:         "http://example.com",
		FromAddress: "From Address <from@example.com>",
	}

	expected := PhishingTemplateContext{
		URL:           fmt.Sprintf("%s?user_id=%s", ctx.URL, r.RId),
		BaseURL:       ctx.URL,
		BaseRecipient: r.BaseRecipient,
		TrackingURL:   fmt.Sprintf("%s/track?user_id=%s", ctx.URL, r.RId),
		From:          "From Address",
		RId:           r.RId,
		// Sample QR Code
		//QRBase64: "iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQMAAABKLAcXAAAABlBMVEX///8AAABVwtN+AAABL0lEQVR42pTUsa3mIBAE4LEcENIAMm0QnERL7gA6oCWkF9AG1t/AvswB8pyw5Ox+zpB9kWfXAyCZ7KkvaFImJFCxKblUAvahflkSc+CpbZtUhNuX/EqfQmBSApWM07Y8qb+qz27cfpT0bOKd+rE5HCee802/VclKgUP9s09If05tlGw+1VWGEvhkoO0J3rOPBKyMS4k92XstH8amUnW672yo5kJ1qD5VLxMiyZVyOW3zPhTWjIpQvVw92mvdzfJy5HDkfSgYh6bEnvrof/q1+GFqTl8OW2/WQLBnWBmP3kEMxeYFPtpC/sQJAdDGYSmx34eReq+bIkvaMKP+FlQX+id/ZKi+XUta3snmZDxJsf9XWnPYsG9eJtRzGmiouGQMdd9+f8/1vBr/1t8AAAD//57YkMe1MUVFAAAAAElFTkSuQmCC",
		//QRName:   "1157331016.png",
		//QR:       "<img src=\"cid:1157331016.png\">",
	}
	expected.Tracker = "<img alt='' style='display: none' src='" + expected.TrackingURL + "'/>"
	got, err := NewPhishingTemplateContext(ctx, r.BaseRecipient, r.RId)
	c.Assert(err, check.Equals, nil)
	c.Assert(got, check.DeepEquals, expected)
	// Note: It is currently expected that the assertion will fail for the QRName.
}

// /usr/bin/go test -check.f "ModelsSuite.TestNewTemplateContext" -v
