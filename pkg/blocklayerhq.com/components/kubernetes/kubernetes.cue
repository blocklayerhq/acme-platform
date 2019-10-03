package kubernetes

import (
	"encoding/json"
	"blocklayerhq.com/bl"
)

GKE Deployment: bl.Component & {

	auth: {}// FIXME: GKE key schema goes here

	settings: {
		zone: *"us-west2a"|string
		cluster: string
		namespace: string
	}

	install: {
		packages: {
			"gcloud-cli": {}
			"shopify-kubernetes-deploy": {}
			"kubectl": {}
			"jq": {}
		}
		installCmd: #"""
			\#(_google_auth_cmd)
			kubectl create ns $namespace || true
		"""#
		removeCmd: #"""
			echo FIXME: delete/cleanup namespace here
		"""#
	}

	push: #"""
		\#(_google_auth_cmd)
		REVISION=HEAD kubernetes-deploy \
			--template-dir=input/ \
			'\#(settings.namespace)' \
			"$(kubectl config current-context)"
		"""#

	_google_auth_cmd: #"""
		# 1. Authenticate to gcloud
		export CLOUDSDK_CONFIG=$(pwd)/cache/gcloud/gcloud-config
		if [ -d cache/gcloud ]; then
			echo "Reusing gcloud credentials from cache"	
		else
			echo "Generating Google Cloud configuration"
			mkdir cache/gcloud
			mkdir $CLOUDSDK_CONFIG
			gcloud -q auth activate-service-account --key-file=<(cat <<EOF\#n\#(json.Marshal(auth))\#nEOF\#n)
			gcloud -q config set project '\#(auth.project_id)'
			gcloud -q config set compute/zone '\#(settings.zone)'
		fi
		# 2. Kubernetes-specific Google Cloud configuration
		export KUBECONFIG=$(pwd)/cache/gcloud/kubernetes-config
		# Set GKE cluster
		gcloud -q config set container/cluster '\#(settings.cluster)'
		# Set kubectl credentials to GKE cluster
		gcloud -q beta container clusters get-credentials '\#(settings.cluster)'
		"""#
}
