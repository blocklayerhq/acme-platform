#!/bin/bash

set -e

. deploy.env.secret

FLAGS=(
	-o netlify.deploy.web.site-id=STRING:"$NETLIFY_SITE_ID"
	-o netlify.deploy.web.auth-token=STRING:"$NETLIFY_AUTH_TOKEN"
	-o fs.write_text.web_self_url.text=STRING:APP_URL="$WEB_URL"
	-o fs.write_text.web_api_url.text=STRING:APP_URL_API="$API_URL"
	-o gcr.push.backend.service-key=STRING:"$GCLOUD_SERVICE_KEY"
	-o gcr.push.backend.project=STRING:"$GCLOUD_PROJECT"
	-o kubernetes.kustomize.backend.src=FSTREE:./codeamp/backend-k8s
	-o gke.deploy.backend.project=STRING:"$GCLOUD_PROJECT"
	-o gke.deploy.backend.region=STRING:"$GCLOUD_COMPUTE_ZONE"
	-o gke.deploy.backend.service-key=STRING:"$GCLOUD_SERVICE_KEY"
	-o gke.deploy.backend.kubernetes-cluster=STRING:"$KUBERNETES_CLUSTER"
	-o gke.deploy.backend.namespace=STRING:"$KUBERNETES_NAMESPACE"
)

if [ "$UPSTREAM" ]; then
	echo "---> Building from upstream repositories"
else
	echo "---> Buildinfg from local repositories"
	FLAGS+=(
		-o npm.build.web.src=FSTREE:./crate/code/web/
	)
fi

if [ "$DEV" ]; then
	echo "---> Running pipeine with local development flags"
	FLAGS+=(
		--workdir /tmp/bl
		--no-versioning
	)
fi

blrun() {
	bl-runtime run "${FLAGS[@]}" -f ./acme-clothing.pipeline "$@" 
}

if [ "$PRETTY" ]; then
	echo "---> Prettifying pipeline output"
	blrun "$@" 2>&1 | jq -r 'select(.level == "error" or .log_output == "stdout" or .log_output == "stderr" or .level == "fatal") | .level + " " + .bot_id + ": " + .message + .error'
else
	blrun "$@"
fi
