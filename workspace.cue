package myblconfig

import (
	"acme.infralabs.io/acmeclothing"
)


// FIXME: move this to core bl
env <Addr>: {
	address: Addr
	components <C>: {
		name: C
	}
}

env "acme.infralabs.io": {
	components "acme-clothing": acmeclothing.AcmeClothing & {
		subcomponents: {
			api subcomponents: {
				container settings registry: "gcp.io/deploy-test-231020"
				db settings host: {
					public: "34.94.9.17"
					private: "10.32.225.3"
				}
			}
		}
	}
}
