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

	// Pull requests mapped by ID
	pr: {
		allPrData = Pull.pr.result.data.repository.pullRequests.nodes
		if (allPrData & []) != _|_ {
			for prData in allPrData {
				"\(prData.number)": {
					title: prData.title

					state: "FIXME"
					head: {
						sha:     "FIXME"
						ref:     "FIXME"
						git_url: "FIXME"
						ssh_url: "FIXME"
					}
				}
			}
		}
	}
}
