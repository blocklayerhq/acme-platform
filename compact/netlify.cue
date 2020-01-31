Netlify :: {
	// Official netlify controller
	// https://netlify.com

	// Settings
	siteName:   string
	domain:     string
	createSite: bool | *true
	account:    string | *""

	// Application code to deploy
	Input: {
		optional: false
		pipeline: [
			{
				action: "script"
				code:   "./netlify.code"
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
			},
		]
	}

	Keychain: {
		token: string
	}
}
