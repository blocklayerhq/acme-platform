package bl

Catalog netlify Site: {

	auth: string

	settings: {
		siteName: string
		customDomain: string
		account: *""|string
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
			site_id=$(
				curl \
					-f \
					-H "Authorization: Bearer \#(settings.auth)" \
					https://api.netlify.com/api/v1/\#(settings.account)/sites\?filter\=all \
				| jq -r '.[] | select(.name=="\#(settings.siteName)") | .id'
			)
			if [ -z "$site_id" ] ; then
				response=$(curl -f -H "Authorization: Bearer \#(auth))" \
							-X POST -H "Content-Type: application/json" \
							# FIXME: This doesn't enable HTTPS on the site.
							'https://api.netlify.com/api/v1/\#(settings.account)/sites"
							-d '{"subdomain": "\#(settings.siteName)", "custom_domain": "\#(settings.customDomain)"}'
						)
				[ $? -ne 0 ] && echo "create site failed" && exit 1
				site_id=$(jq -r '.site_id' <<<$response)
			fi
			echo "$site_id" > info/siteID
			"""#
	}

	push: #"""
		netlify deploy \
		    --dir="input/" \
		    --auth='\#(settings.auth)'
		    --site="\#(info.siteID)" \
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
