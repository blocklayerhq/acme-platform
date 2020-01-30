package acme

// Acme: acme clothing application

settings: domain: string | *"acme.infralabs.io"

block: {
	domain = settings.domain

	staging: App & {
		settings: {
			hostname: "staging.\(domain)"
			netlifySiteName: "acme-staging"
		}
		keychain: netlifyToken: shNetlifyToken
	}

	// pr: {
	// 	block: [prId=int]: App & {
	// 		settings: hostname: "\(prId).pr.\(domain)"
	// 		// FIXME: intentionally omitted netlify siteName to trigger a cue error
	// 	}
	// }
	// sandbox: {
	// 	block: [sandboxId=string]: App & {
	// 		settings: hostname: "\(sandboxId).dev.\(domain)"
	// 		// FIXME: intentionally omitted netlify siteName to trigger a cue error
	// 	}
	// }
}
