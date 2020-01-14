// Acme: acme clothing application

settings: domain: string | *"acme.infralabs.io"

block: {
	domain = settings.domain

	staging: App & {
		settings: hostname: "staging.\(domain)"
	}

	pr: {
		block: [prId=int]: App & {
			settings: hostname: "\(prId).pr.\(domain)"
		}
	}
	sandbox: {
		block: [sandboxId=string]: App & {
			settings: hostname: "\(sandboxId).dev.\(domain)"
		}
	}
}
