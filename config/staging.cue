package main

env: staging: AcmeEnv & {
	input: {
		hostname: "staging.acme.infralabs.io"
		apiHostname: "staging.acme-api.infralabs.io"
		netlifySite: "acme-demo"
	}
}
