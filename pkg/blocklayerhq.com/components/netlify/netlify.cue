package netlify

component netlify Site: {
	settings: {
		auth: string
		siteName: string
		customDomain: string
	}

	info: {
		URL: string
		logsURL: string
		uniqueDeployURL: string
		siteID: string // Set by install(), used by push()
	}

	install: {
		packages: {
			rsync: {}
			yarn packages: {
				"netlify-cli": {}
			}
			jq: {}
		}
		installCmd: #"""
			create_site() {
				# FIXME: This doesn't enable HTTPS on the site.
				url="https://api.netlify.com/api/v1/$(cat inputs/account)/sites"
	
				request=$(jq -n \
					--arg name "$(get_name)" \
					'{"subdomain": $name}' \
					)
				if [ -f inputs/custom-domain ]; then
					request=$(echo $request | jq \
						--arg custom_domain "$(cat inputs/custom-domain)" \
						'. + {custom_domain: $custom_domain}')
				fi
				response=$(curl -f -H "Authorization: Bearer $(cat inputs/auth-token)" \
							-X POST -H "Content-Type: application/json" \
							$url \
							-d "$request"
						)
				[ $? -ne 0 ] && echo "create site failed" && exit 1
	
				echo $response | jq -r '.site_id'
			}
			site_id=$(
				curl \
					-f \
					-H "Authorization: Bearer \#(settings.auth)" \
					https://api.netlify.com/api/v1/sites\?filter\=all \
				| jq -r '.[] | select(.name=="\#(settings.siteName)") | .id'
			)
			if [ -z "$site_id" ] ; then
				site_id=$(create_site)
			fi
			echo "$site_id" > info/siteID
			"""#
	}

	push: #"""
		if [ ! -s info/siteID ]; then
			echo >&2 'undefined site ID. Component may not be properly installed.'
			return 1
		fi
		netlify deploy \
		    --dir="input/" \
		    --auth='\#(settings.auth)'
		    --site="$(cat info/siteID)" \
		    --message="Blocklayer 'netlify deploy'" \
		    --prod \
		| tee tmp/stdout

		# enable SSL
		curl -i -X POST "https://api.netlify.com/api/v1/sites/${site_id}/ssl"

		<tmp/stdout sed -n -e 's/^Live URL:.*\(https:\/\/.*\)$/\1/p' > info/URL
		<tmp/stdout sed -n -e 's/^Logs:.*\(https:\/\/.*\)$/\1/p' > info/logsURL
		<tmp/stdout sed -n -e 's/^Unique Deploy URL:.*\(https:\/\/.*\)$/\1/p' > info/uniqueDeployURL
		
	"""#
}
