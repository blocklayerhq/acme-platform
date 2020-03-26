package acme

import (
	"encoding/json"
	"strings"

	"acme.infralabs.io/kubernetes"
	"acme.infralabs.io/aws/eks"
	"acme.infralabs.io/aws/aurora"
)

API :: {
	hostname: string
	url:      "https://\(hostname)"

	// FIXME: parametrize the container image
	containerImage: "samalba/crate-api-tmp"

	// AWS configuration shared by EKS and Aurora
	aws: {
		region: string
		accessKey: secret
		secretKey: secret
	}

	// Configure the NodeJS API server
	js: {
		config: {
			production: {
				username: db.adminAuth.username
				password: db.adminAuth.password
				database: db.name
				// FIXME: make db host configurable
				host:          "bl-demo-rds.cluster-cd0qkdyvpxkj.us-west-2.rds.amazonaws.com"
				dialect:       "mysql"
				seederStorage: "sequelize"
			}
		}
	}

	// API is backed by a MySQL database on an AWS Aurora server.
	// The server is provisioned out-of-band.
	db: aurora.DB & {
		// Database name
		// (a DB is created automatically on the server for each deployment)
		name: strings.Split(hostname, ".")[0]
		awsConfig: aws
		// FIXME: make ARNs configurable, or even better, provision them dynamically
		arn:       "arn:aws:rds:us-west-2:125635003186:cluster:bl-demo-rds"
		secretArn: "arn:aws:secretsmanager:us-west-2:125635003186:secret:bl-demo-rds-1-cSl1C4"
	}

	// The API server is deployed on a Kubernetes cluster (AWS EKS)
	kub: {
		// Kubernetes auth configuration (from kubectl config)
		auth: secret

		// Full kubernetes config
		config: {
			// 1. Load base config from attached yaml file
			(kubernetes.LoadYaml & {
				input: attachment["api_kube.yaml"].contents
			}).output

			// 2. Ingress overlay
			ingressroute: ingressroutetls: spec: {
				routes: [routes[0] & {
					match: "Host(`\(hostname)`)"
				}]
			}
			// 3. Image name overlay (container and initContainer)
			deployment: "acme-clothing-api": spec: template: spec: {
				containers: [containers[0] & {
					image: containerImage
				}]
				initContainers: [initContainers[0] & {
					image: containerImage
				}]
			}
			// 4. Secret overlay (with db config for js app)
			secret: "api-db-config": {
				secretData=json.Marshal(js.config)
				stringData: json: secretData
			}
		}

		// Deploy the configuration on EKS cluster
		deployment: eks.Deployment & {
			namespace:      strings.Replace(hostname, ".", "-", -1)
			// FIXME: for now we only pass the raw yaml string without values inserted
			kubeConfig: config
			kubeAuthConfig: auth
			awsConfig: aws
		}

	}
}
