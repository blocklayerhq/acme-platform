package main

import (
	"strings"
	"encoding/json"
	"text/template"
    "b.l/bl"
)

AcmeAPI :: {
	hostname: string | *"toto"
	url: "https://\(hostname)"
	inputKubeAuth=kubeAuthConfig: bl.Secret
	inputAWSConfig=awsConfig: {
		region: "us-west-2"
		accessKey: bl.Secret
		secretKey: bl.Secret
	}
	inputDBConfig=dbConfig: {
		adminUsername: bl.Secret
		adminPassword: bl.Secret
	}

	kub: KubernetesApp & {
		namespace: strings.Replace(hostname, ".", "-", -1)

		// FIXME: the container is hardcoded, it should be built by a native docker.Image task
		containerImage: "samalba/crate-api-tmp"
		kubeAuthConfig: inputKubeAuth
		awsConfig: inputAWSConfig

		kubeConfigYAML: template.Execute(kubeTemplate, {
			APIHostname: "hostname"
			ContainerImage: containerImage
			DBConfig: json.Marshal({
				production: {
					username: inputDBConfig.adminUsername
					password: inputDBConfig.adminPassword
					database: db.dbName
					host:     "bl-demo-rds.cluster-cd0qkdyvpxkj.us-west-2.rds.amazonaws.com"
					dialect:  "mysql"
					seederStorage: "sequelize"
				}
			})
		})
	}

	db: RDSAurora & {
		dbName: strings.Split(hostname, ".")[0]
		arn: "arn:aws:rds:us-west-2:125635003186:cluster:bl-demo-rds"
		secretArn: "arn:aws:kms:us-west-2:125635003186:key/a3657780-9e5c-445b-b6f4-d553f3e70118"
		awsConfig: inputAWSConfig
		adminAuth: {
			username: dbConfig.adminUsername
			password: dbConfig.adminPassword
		}
	}

}
