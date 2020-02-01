package main

// Acme: acme clothing application

settings: domain: string | *"acme.infralabs.io"

block: {
	domain = settings.domain

	staging: App & {
		settings: hostname: "staging.\(domain)"
		block: frontend: {
			block: deploy: {
				settings: siteName: "acme-staging"
				keychain: token: shNetlifyToken
			}
		}
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
