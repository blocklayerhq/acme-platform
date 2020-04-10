package main

// Environment to deploy a full review environment for each pull request on the monorepo,
// then post its URL as a comment on the pull request.

env: prReview: {

	monorepo = env.devInfra.config.monorepo

	output: monorepo.pr
}
