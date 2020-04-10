package main

env: devInfra: {
	config: monorepo: {
		Pull: pr: query: result: {
			data: repository: pullRequests: nodes: [
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
