// Acme: acme clothing application
package main

import (
	"stackbrew.io/github"
	"acme.infralabs.io/acme"
)

// Advanced ACME dev stack
AcmeAdvanced :: {
	// github.com/blocklayerhq/acme-clothing
	monorepo: github.Repository & {
		owner: *"blocklayerhq" | string
		name: *"acme-clothing" | string
	}
	
	// Top-level domain for all web endpoints
	domain: *"acme.infralabs.io" | string
	// Top-level domain for all api endpoints
	apiDomain: *"acme-api.infralabs.io" | string
	
	// Staging instance
	staging: acme.App & {
		frontend: hostname: "staging.\(domain)"
		// api: hostname: "staging.\(apiDomain)"
		frontend: site: name: "acme-demo"
	}
	
	// Deploy a review instance for each PR
	prReview: {
		for prId, pr in monorepo.pr {
			"\(prId)": acme.App & {
				frontend: hostname: "pr-\(prId).\(domain)"
				// api: hostname: "pr-\(prId).\(apiDomain)"
				frontend: site: name: "acme-pr-\(prId)"
				monorepo: pr.branch.tip.checkout
			}
			pr: info: """
				✅ Blocklayer Pipeline Completed
				|Output|Type|Value|
				|------|------|-----|
				|url   |string|\(prReview.prId.url)|
				|api_url | string | \(prReview.prId.api.url)|
				|git_commit | string | \(pr.branch.tip.commitId) |
				"""
		}
	}
}
