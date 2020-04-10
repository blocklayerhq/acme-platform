package github

import (
	"encoding/json"

	"b.l/bl"
	"acme.infralabs.io/github/v4"
)

Repository :: {
	// Github API token
	token: bl.Secret

	// Github repository name
	name: string

	// Github repository owner
	owner: string

	Pull: pr: v4.ListPullRequests & {
		endpoint: "token": token
		repoOwner: owner
		repoName:  name
	}

	pr: Pull.pr.result
}
