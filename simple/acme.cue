// Acme: acme clothing application

App & {
	settings: hostname: "demo.acme.infralabs.io"
	block: frontend: {
		block: deploy: {
			settings: siteName: "acme-demo"
			keychain: token: solomonNetlifyToken
		}
	}
}
