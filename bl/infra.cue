package main

import (
	"acme.infralabs.io/acme"
	"stackbrew.io/github"
)

// Environment to manage all development infrastructure
// - Netlify account for web deployment
// - AWS account for API deployment
// - Github account for monorepo access
//
// The environment includes a definition `Deployment` which
// can be used by other environments to easily deploy a full
// development stack on top of this infrastructure.

env: devInfra: {

	input: {

		// Master switch to enable/disable deployment tasks
		online: *"1" | "0"

		/////////////////
		// DNS SETTINGS
		////////////////

		// Top-level dev domain for all web endpoints
		webDomain: "dev.acme.infralabs.io"

		// Top-level dev domain for all api endpoints
		apiDomain: "dev.acme-api.infralabs.io"

		/////////////////
		// FRONTEND DEPLOYMENT INFRA
		/////////////////

		// Netlify API token
		netlifyToken: secret

		// Netlify team name
		netlifyTeam: string | *"blocklayer"

		/////////////////
		// API DEPLOYMENT INFRA
		/////////////////

		// AWS secret key
		awsSecretKey: secret

		// AWS access key
		awsAccessKey: secret

		// AWS region
		awsRegion: string | *"us-west-2"

		// Admin username for the database server
		dbAdminUser: secret

		// Admin password for the database server
		dbAdminPassword: secret

		// Kubernetes client config with EKS credentials
		// To produce this input, you need kubectl installed on your machine,
		// and configured to connect to your EKS cluster.
		kubeAuth: secret

		/////////////////
		// GITHUB INFRA
		/////////////////

		// Github API token
		githubToken: secret

		// Owner of the github repo
		githubRepoOwner: string | *"blocklayerhq"

		// Name of the github repo
		githubRepoName: string | *"acme-clothing"

		// Queue of inbound github events
		// FIXME: not yet implemented in the github package
		// FIXME: for now we just keep the last event
		githubEvents: github.Event
	}

	config: {

		monorepo: github.Repository & {
			token: input.githubToken
			owner: input.githubRepoOwner
			name:  input.githubRepoName
		}

		// FIXME: automate infrastructure provisioning
		// Currently it is done out-of-band (terraform for API,
		// manually for frontend).
	}

	// A full deployment of the ACME stack on the dev infra
	// This can be used from other environments
	Deployment :: acme.App & {
		// If name is set, use it to auto-generate hostnames
		name: string

		// Monorepo checkout to deploy
		// By default, deploy from master on the upstream monorepo
		source: directory | *config.monorepo.master.tip.checkout

		web: {
			hostname: string | *"\(name).\(input.webDomain)"
			netlifyAccount: {
				name:  input.netlifyTeam
				token: input.netlifyToken
			}
		}
		api: {
			hostname: string | *"\(name).\(input.apiDomain)"
			aws: {
				region:    input.awsRegion
				accessKey: input.awsAccessKey
				secretKey: input.awsSecretKey
			}
			kub: auth: input.kubeAuth
			kub: deployment: online: (input.online == "1")
			db: adminAuth: {
				username: input.dbAdminUser
				password: input.dbAdminPassword
			}
		}
	}
}
