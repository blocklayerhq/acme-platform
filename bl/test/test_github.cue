package main

env: devInfra: {
	config: monorepo: {

		lastEvent: {
			pull_request: {
				number: 40
			}
		}

		Pull: pr: query: result: {
			data: repository: pullRequests: nodes: [
				{
					"number": 40
					title: "remove old README"
				},
				{
					"number": 42
					"title":  "great pull request"
				},
				{
					"number": 28
					"title":  "even better pull request"
				},
			]
		}
	}
}
