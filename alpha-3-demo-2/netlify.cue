Netlify :: {
	// Official netlify controller
	// https://netlify.com
	
	// Application code to deploy
	input: true
	
	info: url: string
	
	settings: {
		siteName: string
		domain: string
		createSite: bool | *true
		account: string | *""
	}
	
	keychain: {
		token: string
	}
	
	// FIXME: missing info: url
	
	code: {
		os: "alpineLinux"
		package: {
			yarn: true
			curl: true
			jq: true
			rsync: true
		}
		extraCommand: [
			"yarn global add netlify-cli"
		]
		language: "bash"
		dir: "./netlify.code"
	}
}
