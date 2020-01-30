package netlify

// Official netlify controller
// https://netlify.com

// Application code to deploy
input: true

//	info: url: string

settings: {
	siteName:   string
	domain:     string
	createSite: bool | *true
	account:    string | *""
}

keychain: {
	token: string
}

// FIXME: missing info: url

code: {
	os: "alpineLinux"
	package: {
		yarn:  true
		curl:  true
		jq:    true
		rsync: true
	}
	extraCommand: [
		"yarn global add netlify-cli",
	]
	language: "bash"
	dir:      "./netlify.code"

	// FIXME: temporary stopgap
	script: #"""
		set -exu -o pipefail

		create_site() {
			# FIXME: This doesn't enable HTTPS on the site.
			url="https://api.netlify.com/api/v1/$(settings get account)/sites"

			response=$(curl -f -H "Authorization: Bearer $(keychain get token)" \
						-X POST -H "Content-Type: application/json" \
						$url \
						-d "{\"subdomain\": \"$(settings get siteName)\", \"custom_domain\": \"$(settings get domain)\"}"
					)
			[ $? -ne 0 ] && echo "create site failed" && exit 1

			echo $response | jq -r '.site_id'
		}

		site_id=$(curl -f -H "Authorization: Bearer $(keychain get token)" \
					https://api.netlify.com/api/v1/sites\?filter\=all | \
					jq -r ".[] | select(.name==\"$(settings get siteName)\") | .id" \
				)
		if [ -z "$site_id" ] ; then
			if [ "$(settings get createSite)" != true ]; then
				echo "Site $(settings get siteName) does not exist"
				exit 1
			fi
			site_id=$(create_site)
		fi
		netlify deploy \
			--dir="$(pwd)/input" \
			--auth="$(keychain get token)" \
			--site="$site_id" \
			--message="Blocklayer 'netlify deploy'" \
			--prod \
		| tee tmp/stdout

		# enable SSL
		curl -i -X POST "https://api.netlify.com/api/v1/sites/${site_id}/ssl"

		<tmp/stdout sed -n -e 's/^Live URL:.*\(https:\/\/.*\)$/\1/p' > info/url
		"""#
}
