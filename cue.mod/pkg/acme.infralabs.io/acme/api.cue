package acme

import (
	"strings"
	"stackbrew.io/mysql"
	"stackbrew.io/nodejs"
	"stackbrew.io/kubernetes"
	"stackbrew.io/googlecloud"
)

Api :: {
	hostname: string
	url: "https://\(hostname)"

	// Google Cloud project used for GKE and GCR
	// This requires service key, project, etc.
	gcp: googlecloud.Project & {
		id: "deploy-test-231020"
	}

	container: nodejs.Container & {
		buildScript: "build:prod"
		runScript: "start:server"
		environment: NODE_ENV: "production"
	}

	// Use source code digest as a reliable tag to push to.
	// This enforces immutability, as long as nobody else overwrites the tag.
	// FIXME: currently bl.Directory does not expose a `digest` field
	// safeTag = container.source.digest
	safeTag = "FIXME"

	repository: gcp.GCR.Repository & {
		name: *"acme-clothing-api" | string
		// Push to a safe, immutable tag
		tag: "\(safeTag)": container.image
		// Also push to latest for historical reasons
		tag: latest: container.image
		// Remove all unknown tags from the repository
		unknownTags: "remove"
	}

	// kubernetes.App is a cloud-agnostic abstraction for deploying an application
	// to a kubernetes namespace. Kube implementation and transport is swappable.
	// This is a similar pattern to the SQL interface in Go.
	kub: kubernetes.App & {
		// Use legacy yaml config as a base, and add a "smart" overlay
		baseConfig = (kubernetes.YamlDirectory & { dir: "./kubernetes_base" }).config
		config: baseConfig & {
			deployment: "acme-clothing-api": spec: {
				container: api: image: "\(repository.ref):\(safeTag)"
				initContainer: "db-setup": image: container.api.image
			}
			ingress: "api-public-endpoint": spec: {
				tls: hosts: "\(hostname)": true
				rules: host: "\(hostname)": {
					http: path: "/": backend: {
						serviceName: "acme-clothing-api"
						servicePort: 8000
					}
				}
			}
			secret: "api-db-config": stringData: json: json.Marshal(db.appConfig)
		}
		// swappable implementation goes here
		cluster: gcp.GKE.Cluster & {
			name: *"cluster"|string
			zone: *"us-west2" | string
			create: *true | bool
		}
		namespace: *strings.Replace(hostname, ".", "-") | string
		// If the namespace contains unknown resources, report an error.
		// This requires operators to manually resolve the divergence.
		unknownResources: "error"
	}

	db: {
		// FIXME: we use Google Cloud SQL, so we should use
		// the native GCP package for this.
		mysql.Database & {
			// Use the API hostname as a default database name
			name: *hostname | string
			// Automatically create the database by default
			create: *true | bool
		}

		// DB credentials formatted in our app-specific format
		// Inject this at runtime as a json file in the application container.
		// Currently we do this with a Kubernetes secret.
		appConfig: {
			production: {
				// FIXME: don't give db admin privileges to the app!
				username: db.server.adminUser
				password: db.server.adminPassword
				database: db.name
				host: db.server.host
				dialect: "mysql"
				seederStorage: "sequelize"
			}
		}
	}
}

