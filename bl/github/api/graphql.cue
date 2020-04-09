package api

import (
	"b.l/bl"

	"acme.infralabs.io/graphql"
)

Endpoint :: {
	url:   string | *"https://api.github.com/graphql"
	token: bl.Secret
}

// GraphQL query to list pull requests for a repository
ListPullRequests :: {
	endpoint: Endpoint

	repoOwner: string
	repoName:  string
	pageSize:  int | *100

	graphql.Query & {
		url:   endpoint.url
		token: endpoint.token
		query:
			"""
		repository(owner: "\(repoOwner)", name: "\(repoName)") {
			pullRequests(last:\(pageSize), states: OPEN) {
				nodes {
					number
					title
				}
			}
		}
		"""
	}
}
