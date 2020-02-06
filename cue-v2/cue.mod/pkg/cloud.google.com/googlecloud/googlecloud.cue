package googlecloud

import (
	"b.l/bl"
	"kubernetes.io/kubernetes"
)

Project :: {
	id: string
	account: {
		key: {
			// FIXME: google cloud service key schema
			...
		}
	}

	GCR: {

		// A GCR container repository
		Repository: {
			name: string
			tag: [string]: bl.Directory
			unknownTags: "remove" | *"ignore" | "error"
			ref: "gcr.io/\(name)"
		}

	}

	GKE: {

		// A GKE cluster
		Cluster: kubernetes.Cluster & {
			name: string
			zone: *"us-west1" | string
			create: *true | bool
		}
	}

	// TODO: Google Cloud SQL controller
	SQL: {}
}
