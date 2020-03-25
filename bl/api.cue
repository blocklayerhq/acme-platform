package main

import (
	"strings"

	"acme.infralabs.io/kubernetes"
)

AcmeAPI :: {
	hostname: string
	url:      "https://\(hostname)"

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
	db: AuroraDB & {
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

		// Base config parsed from raw yaml file.
		// NOTE: raw yaml is inlined in api_kube_yaml.cue, until we support dynamic yaml loading
		baseConfigFile: kubernetes.ConfigFile

		config: kubernetes.Config & {
			baseConfigFile.resource
			// FIXME: lists are a pain to merge
			ingressroute: ingressroutetls: spec: {
				routeBase=routes[0]
				routeOverlay={match: "Host(`\(hostname)`)"}
				routes: [routeBase & routeOverlay]
			}
		}

		// Deploy the configuration on EKS cluster
		deployment: EKSDeployment & {
			online: false
			namespace:      strings.Replace(hostname, ".", "-", -1)
			// FIXME: for now we only pass the raw yaml string without values inserted
			kubeConfig: config
			kubeAuthConfig: auth
			awsConfig: aws
		}

	}
}
