package acme

// Configuration template for a complete ACME environment
App :: {
	name:             string | *""
	appSource=source: directory

	api: API
	web: Frontend & {
		apiHostname: api.hostname
		source:      directory & {
			from: appSource
			path: "crate/code/web"
		}
	}
}
