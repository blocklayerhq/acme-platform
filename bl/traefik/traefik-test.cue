package traefik

test: simpleIngress: {

	def: {
		i: KubSimpleIngress & {
			name: "api"
			certResolver: "acmeresolver"
			match: "Host(`localhost`)"
			service: {
				name: "acme-api"
				port: 8000
			}
		}
	}
}
