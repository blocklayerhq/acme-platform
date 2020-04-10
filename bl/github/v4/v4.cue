package v4

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

	result: {
		for prData in query.result.data.repository.pullRequests.nodes {
			"\(prData.number)": {
				title: prData.title
				state: prData.state
				head: {
					sha:     prData.headRef.target.oid
					ref:     prData.headRef.name
					git_url: prData.headRepository.url
					ssh_url: prData.headRepository.sshUrl
				}
			}
		}
	}

	// The graphql query
	query: graphql.Query & {
		url:   endpoint.url
		token: endpoint.token

		result: {
			data: {
				repository: {
					pullRequests: {
						nodes: [...{
							state: string
							number: int
							title: string
							headRepository: {
								url: string
								sshUrl: string
							}
							headRef: {
								name: string
								prefix: string
								target: {
									oid: string
								}
							}
						}]
					}
				}
			}
		}

		query:
			"""
			repository(owner: "\(repoOwner)", name: "\(repoName)") {
				pullRequests(last:\(pageSize), states: OPEN) {
					nodes {
						state
						number
						title
						headRepository {
							sshUrl
							url
						}
						headRef {
							name
							prefix
							target {
								oid
							}
						}
					}
				}
			}
			"""
	}
}
