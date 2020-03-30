package traefik

import (
	"acme.infralabs.io/kubernetes"
)

KubIngress :: {
	apiVersion: "traefik.containo.us/v1alpha1"
	kind: "IngressRoute"
	metadata: name: string
	spec: {
		entryPoints: ["websecure"]
		routes: [r for _, r in route]
	}
}

}

KubSimpleIngress :: {
	n=name: string
	cr=certResolver: string
	m=match: string
	service: Service

	route: [routeName=string]: Route
	route: default: Route & {
			services: [service]
			match: m
	}

	Service :: {
		name: string
		port: int
	}

	Route :: {
		kind: "Rule"
		services: [...Service]
		match: string
		tls: certResolver: cr
	}

	output: kubernetes.Config & {
		ingressroute: "\(n)": {
			apiVersion: "traefik.containo.us/v1alpha1"
			kind: "IngressRoute"
			metadata: name: n
			spec: {
				entryPoints: ["websecure"]
				routes: [r for _, r in route]
			}
		}
	}
}
