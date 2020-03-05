// Acme: acme clothing application
package main

import (
	"acme.infralabs.io/acme"
)

AcmeSimple :: {
	staging: acme.App & {
		// api: hostname: "staging.acme-api.infralabs.io"
		frontend: {
			site: name: "acme-demo"
			hostname: "staging.acme.infralabs.io"
		}
	}
}
