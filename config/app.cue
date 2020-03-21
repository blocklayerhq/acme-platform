package main

// Configuration template for a complete ACME environment
AcmeApp :: {
	name:             string | *""
	appSource=source: directory

	api: AcmeAPI
	web: AcmeFrontend & {
		apiHostname: api.hostname
		source:      directory & {
			from: appSource
			path: "crate/code/web"
		}
	}
}
