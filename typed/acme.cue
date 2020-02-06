// Acme: acme clothing application

domain: *"acme.infralabs.io" | string
apiDomain: *"acme-api.infralabs.io" | string

staging: App & {
	frontend: hostname: "staging.\(domain)"
	api: hostname: "staging.\(apiDomain)"
	frontend: netlifySite: name: "acme-demo"
}

pr: [prId=string]: App & {
	frontend: hostname: "pr-\(prId).\(domain)"
	api: hostname: "pr-\(prId).\(apiDomain)"
	frontend: netlifySite: name: "acme-pr-\(prId)"
}
