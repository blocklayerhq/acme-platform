Netlify :: Block & {
	// Official netlify controller
	// https://netlify.com

	// Application code to deploy
	input: true

	info: url: string

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
				url="https://api.netlify.com/api/v1/$(get setting account)/sites"

				response=$(curl -f -H "Authorization: Bearer $(get keychain token)" \
							-X POST -H "Content-Type: application/json" \
							$url \
							-d '{"subdomain": "$(get setting siteName)", "custom_domain": "$(get setting domain)"}'
						)
				[ $? -ne 0 ] && echo "create site failed" && exit 1

				echo $response | jq -r '.site_id'
			}

			site_id=$(curl -f -H "Authorization: Bearer $(get keychain token)" \
						https://api.netlify.com/api/v1/sites\?filter\=all | \
						jq -r ".[] | select(.name==\"$(get setting siteName)\") | .id" \
					)
			if [ -z "$site_id" ] ; then
				if [ "$(get setting createSite)" != 1 ]; then
					echo "Site $(get setting siteName) does not exist"
					exit 1
				fi
				site_id=$(create_site)
			fi
			netlify deploy \
				--dir="$(pwd)/input" \
				--auth="$(get keychain token)" \
				--site="$site_id" \
				--message="Blocklayer 'netlify deploy'" \
				--prod \
			| tee tmp/stdout

			# enable SSL
			curl -i -X POST "https://api.netlify.com/api/v1/sites/${site_id}/ssl"

			<tmp/stdout sed -n -e 's/^Live URL:.*\(https:\/\/.*\)$/\1/p' > info/url
			"""#
	}
}

