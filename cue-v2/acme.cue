package acme

import (
	"github.com/github"
)

// Acme: acme clothing application

domain: *"acme.infralabs.io" | string
apiDomain: *"acme-api.infralabs.io" | string

staging: App & {
	frontend: hostname: "staging.\(domain)"
	api: hostname: "staging.\(apiDomain)"
	frontend: site: name: "acme-demo"
}

monorepo: github.Repository & {
	owner: *"blocklayerhq" | string
	name: *"acme-clothing" | string
}

prReview: {
	for prId, pr in monorepo.pr {
		"\(prId)": App & {
			frontend: hostname: "pr-\(prId).\(domain)"
			api: hostname: "pr-\(prId).\(apiDomain)"
			frontend: site: name: "acme-pr-\(prId)"
			monorepo: pr.branch.tip.checkout
		}
	}
}
