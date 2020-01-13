package acme

// Acme: acme clothing application

settings: domain: string | *"acme.infralabs.io"

// FIXME: how to define info values in the cue config? Is it possible?

block: staging: {
	from: App
	withSettings: hostname: "staging.\(settings.domain)"
}

block: pr: block: [prId=int]: {
	from: App
	withSettings: hostname: "\(prId).pr.\(settings.domain)"
}

block: sandbox: block: [sandboxId=string]: {
	from: App
	withSettings: hostname: "\(sandboxId).dev.\(settings.domain)"
}
