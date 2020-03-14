package main

import (
		"text/template"
		"b.l/bl"
)

kubeTemplate: """
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
    name: ingressroutetls
spec:
    entryPoints:
      - websecure
    routes:
    - match: Host(`{{ .APIHostname }}`)
      kind: Rule
      services:
      - name: acme-clothing-api
        port: 8000
    tls:
        certResolver: acmeresolver
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
    name: acme-clothing-api
spec:
    replicas: 1
    template:
        metadata:
            labels:
              app: acme-clothing-api
        spec:
            volumes:
             - name: api-db-config
               secret:
                 secretName: api-db-config
                 items:
                 - key: json
                   path: json
            containers:
              - image: $CONTAINER_IMAGE
                name: api
                command: ["npm", "run", "start:server"]
                volumeMounts:
                  - name: api-db-config
                    subPath: json
                    mountPath: /src/build/config/database.json
                    readOnly: true
                ports:
                  - name: api-port
                    containerPort: 8000
                  - name: debug-port
                    containerPort: 8001
                env:
            initContainers:
              - name: db-setup
                image: $CONTAINER_IMAGE
                command: ["npm", "run", "setup:db"]
                env:
                volumeMounts:
                  - name: api-db-config
                    subPath: json
                    mountPath: /src/src/config/database.json
                    readOnly: true
---
apiVersion: v1
kind: Service
metadata:
    name: acme-clothing-api
spec:
    selector:
        app: acme-clothing-api
    ports:
        - name: api-port
          port: 8000
          targetPort: 8000
        - name: debug-port
          port: 8001
          targetPort: 8001
---
apiVersion: v1
kind: Secret
metadata:
    name: api-db-config
type: Opaque
stringData:
    json: '
        $DB_CONFIG
    '
"""

KubernetesApp :: {
	// FIXME: it would be nicer to manipulate config files in Cue directly
	//kubeConfigFiles: [yaml.Unmarshal(d) for d in strings.Split(kubeTemplate, "---")]

	templateData: [string]: string
	kubeConfigYAML: template.Execute(kubeTemplate, templateData)
	namespace: string
	containerImage: string
	kubeAuthConfig: bl.Secret
	awsConfig: {
		region: string,
		accessKey: bl.Secret,
		secretKey: bl.Secret,
	}

	deploy: bl.BashScript & {
		input: {
			"/kube/config.yaml": kubeConfigYAML,
			"/kube/auth": kubeAuthConfig,
			"/kube/namespace": namespace,
			"/aws/region": awsConfig.region,
			"/aws/access_key": awsConfig.accessKey,
			"/aws/secret_key": awsConfig.secretKey
		}

		output: "/info/url": string

		os: {
			package: {
				curl: true
			}
			extraCommand: [
				"curl -L https://dl.k8s.io/v1.14.7/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl",
				"curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator && chmod +x /usr/local/bin/aws-iam-authenticator"
			]
		}

		code: #"""
			export AWS_DEFAULT_REGION="$(cat /aws/region)"
			export AWS_ACCESS_KEY_ID="$(cat /aws/access_key)"
			export AWS_SECRET_ACCESS_KEY="$(cat /aws/secret_key)"
			namespace="$(cat /kube/namespace)"

			export KUBECONFIG=/kube/auth
			kubectl create namespace "$namespace" || true
			kubectl --namespace "$namespace" apply -f /kube/config.yaml

			echo FIXME > /info/url
		"""#
	}
}
