import (
	"b.l/bl"
)

Site :: {
	artifact:	bl.Directory
	siteName:   string
	domain:     string
	createSite: bool | *true
	account:    string | *""
	token: bl.Secret & { value: string }

	script: bl.BashScript & {
		input: artifact
		code: "./netlify.code"
		os: {
			package: {
				yarn:  true
				curl:  true
				jq:    true
				rsync: true
			}
			extraCommand: [
				"yarn global add netlify-cli",
			]
		}
	}
}
