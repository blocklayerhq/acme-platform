// Acme: acme clothing application
package main

staging: AcmeApp & {
	api: hostname: "staging.acme-api.infralabs.io"
	frontend: {
		netlifyAccount: {
			token: _
			name: _
		}
		site: name: "acme-demo"
		hostname: "staging.acme.infralabs.io"
	}
}
