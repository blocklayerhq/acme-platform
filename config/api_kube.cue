package main

import (
		"b.l/bl"
)

KubernetesApp :: {
	// FIXME: it would be nicer to manipulate config files in Cue directly
	//kubeConfigFiles: [yaml.Unmarshal(d) for d in strings.Split(kubeTemplate, "---")]

	kubeConfigYAML: string
	namespace: string
	containerImage: string
	kubeAuthConfig: bl.Secret
	awsConfig: {
		region: string,
		accessKey: bl.Secret,
		secretKey: bl.Secret,
	}

	deploy: bl.BashScript & {
    	runPolicy: "always"

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
			export KUBECONFIG=/kube/auth

			namespace="$(cat /kube/namespace)"
			kubectl create namespace "$namespace" || true
			kubectl --namespace "$namespace" apply -f /kube/config.yaml

			echo FIXME > /info/url
		"""#
	}
}
