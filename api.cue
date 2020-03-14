package main

import (
	"strings"
    "b.l/bl"
)

AcmeAPI :: {
	hostname: string
	url: "https://\(hostname)"
	inputKubeAuth=kubeAuthConfig: bl.Secret
	inputAWSConfig=awsConfig: {
		region: "us-west-2",
		accessKey: bl.Secret,
		secretKey: bl.Secret
	}

	// Use source code digest as a reliable tag to push to.
	// This enforces immutability, as long as nobody else overwrites the tag.
	// FIXME: currently bl.Directory does not expose a `digest` field
	// safeTag = container.source.digest
	safeTag = "FIXME"

	kub: KubernetesApp & {
		namespace: strings.Replace(hostname, ".", "-", -1)

		// FIXME: the container is hardcoded, it should be built by a native docker.Image task
		containerImage: "samalba/crate-api-tmp"
		kubeAuthConfig: inputKubeAuth
		awsConfig: inputAWSConfig

		templateData: {
			// APIHostname: hostname
			APIHostname: "FIXME"
		}
	}

	// db: {
	// 	// FIXME: we use Google Cloud SQL, so we should use
	// 	// the native GCP package for this.
	// 	mysql.Database & {
	// 		// Use the API hostname as a default database name
	// 		name: *hostname | string
	// 		// Automatically create the database by default
	// 		create: *true | bool
	// 	}

	// 	// DB credentials formatted in our app-specific format
	// 	// Inject this at runtime as a json file in the application container.
	// 	// Currently we do this with a Kubernetes secret.
	// 	appConfig: {
	// 		production: {
	// 			// FIXME: don't give db admin privileges to the app!
	// 			username: db.server.adminUser
	// 			password: db.server.adminPassword
	// 			database: db.name
	// 			host: db.server.host
	// 			dialect: "mysql"
	// 			seederStorage: "sequelize"
	// 		}
	// 	}
	//}
}
