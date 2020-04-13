package acme

// Configuration template for a complete ACME environment
App :: {
	name:   string | *""
	source: directory

	api: API
	web: Frontend & {
		apiHostname: api.hostname
		"source":    directory & {
			from: source
			path: "crate/code/web"
		}
	}
}
