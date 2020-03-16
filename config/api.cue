package main

import (
	"strings"
	"encoding/json"
	"text/template"
    "b.l/bl"
)

AcmeAPI :: {
	hostname: *"" | string
	url: "https://\(hostname)"
	inputKubeAuth=kubeAuthConfig: bl.Secret
	inputAWSConfig=awsConfig: {
		region: "us-west-2"
		accessKey: bl.Secret
		secretKey: bl.Secret
	}
	inputDBConfig=dbConfig: {
		// FIXME: should be a bl.Secret
		adminUsername: *"" | string
		adminPassword: *"" | string
		dbName: strings.Split(hostname, ".")[0]
	}

	kub: KubernetesApp & {
		namespace: strings.Replace(hostname, ".", "-", -1)

		// FIXME: the container is hardcoded, it should be built by a native docker.Image task
		containerImage: "samalba/crate-api-tmp"
		kubeAuthConfig: inputKubeAuth
		awsConfig: inputAWSConfig

		kubeConfigYAML: template.Execute(kubeTemplate, {
			APIHostname: hostname
			ContainerImage: containerImage
			DBConfig: json.Marshal({
				production: {
					username: inputDBConfig.adminUsername
					password: inputDBConfig.adminPassword
					database: inputDBConfig.dbName
					host:     "bl-demo-rds.cluster-cd0qkdyvpxkj.us-west-2.rds.amazonaws.com"
					dialect:  "mysql"
					seederStorage: "sequelize"
				}
			})
		})
	}

	db: RDSAurora & {
		dbName: inputDBConfig.dbName
		arn: "arn:aws:rds:us-west-2:125635003186:cluster:bl-demo-rds"
		secretArn: "arn:aws:secretsmanager:us-west-2:125635003186:secret:bl-demo-rds-1-cSl1C4"
		awsConfig: inputAWSConfig
		adminAuth: {
			username: dbConfig.adminUsername
			password: dbConfig.adminPassword
		}
	}

}
