package github

import (
	"b.l/bl"
	"acme.infralabs.io/github/v4"
	"acme.infralabs.io/github/webhook"
)

Repository :: {
	// Github API token
	token: bl.Secret

	// Github repository name
	name: string

	// Github repository owner
	owner: string

	lastEvent?: webhook.Event
	lastPRnumber?: int
	if (lastEvent.pull_request.number & int) != _|_ {
		lastPRnumber: lastEvent.pull_request.number
	}

	Pull: pr: v4.ListPullRequests & {
		endpoint: "token": token
		repoOwner: owner
		repoName:  name
	}

	pr: Pull.pr.result
}
