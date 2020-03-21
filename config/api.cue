package main

import (
	"strings"
	"encoding/json"
	"text/template"
)

AcmeAPI :: {
	hostname: *"" | string
	url:      "https://\(hostname)"

	kub: {
		auth: secret

		// Kubernetes configuration generated from a template
		config: {
			// Raw text of the yaml template
			source: string
			values: {
				APIHostname: hostname
				// FIXME: make container image configurable
				ContainerImage: "samalba/crate-api-tmp"
				DBConfig:       json.Marshal(js.config)
			}
			contents: template.Execute(source, values)
		}

		// Deploy the configuration on EKS cluster
		deployment: EKSDeployment & {
			namespace:      strings.Replace(hostname, ".", "-", -1)
			kubeConfigYAML: config.contents
			kubeAuthConfig: auth
		}
	}

	js: {
		// config file for the nodejs API server
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

	db: AuroraDB & {
		name: strings.Split(hostname, ".")[0]
		// FIXME: make ARNs configurable, or even better, provision them dynamically
		arn:       "arn:aws:rds:us-west-2:125635003186:cluster:bl-demo-rds"
		secretArn: "arn:aws:secretsmanager:us-west-2:125635003186:secret:bl-demo-rds-1-cSl1C4"
	}

}
