package gke

import (
	"encoding/json"
)

gke: {
	slug: _
	
	auth: {
			type: string
			project_id: string
			...
	}// FIXME: GKE key schema goes here
	
	settings: {
		zone: *"us-west2a"|string
		cluster: string
		namespace: *slug|string
	}
	
	install: {
		packages: {
			"gcloud-cli": true
			"shopify-kubernetes-deploy": true
			"kubectl": true
			"jq": true
		}
		installCmd: #"""
			\#(_scripts.googleAuth)
			kubectl create ns $namespace || true
		"""#
		removeCmd: #"""
			echo FIXME: delete/cleanup namespace here
		"""#
	}
	
	push: #"""
		\#(_scripts.googleAuth)
		REVISION=HEAD kubernetes-deploy \
			--template-dir=output/ \
			'\#(settings.namespace)' \
			"$(kubectl config current-context)"
		"""#

	run: #"""
		echo FIXME: merge yaml files in input + generated yaml files from settings
		"""#
	
	_scripts googleAuth: #"""
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
