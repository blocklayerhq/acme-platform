package main

env: staging: {

	input: {

		// Monorepo source checkout to deploy
		// (staging is deployed by direct upload)
		monorepo: directory

		// Netlify API token
		netlifyToken: secret

		// Netlify team name
		netlifyTeam: string

		// AWS secret key
		awsSecretKey: secret

		// AWS access key
		awsAccessKey: secret

		// Admin username for the database server
		dbAdminUser: secret

		// Admin password for the database server
		dbAdminPassword: secret

		// Kubernetes client config with EKS credentials
		// To produce this input, you need kubectl installed on your machine,
		// and configured to connect to your EKS cluster.
		kubeAuthConfig: secret
	}

	output: {
		// Staging URL
		url: config.frontend.url

		// Staging API URL
		apiUrl: config.api.url
	}

	config: {
		api: AcmeAPI & {
			hostname: "staging.acme-api.infralabs.io"
			dbConfig: {
				adminUsername: input.dbAdminUser
				adminPassword: input.dbAdminPassword
			}
			kubeAuthConfig: input.kubeAuthConfig
		}
		frontend: AcmeFrontend & {
			hostname: "staging.acme.infralabs.io"
			apiHostname: api.hostname
			site: {
				name: "acme-demo"
				account: {
					name: input.netlifyTeam
					token: input.netlifyToken
				}
			}
			app: source: directory & {
				from: input.monorepo
				path: "crate/code/web"
			}
		}
	}
}
