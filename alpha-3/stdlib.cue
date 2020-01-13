import (
	"strconv"
	"strings"
)

template: "netlify/site": {
	description: "official netlify controller"

	input: description: "application code to deploy"

	output: false

	settings: {
		// FIXME: where do I put descriptions of settings?
		siteName: string
		domain:   string

		createSite: bool | *true
		account:    string | *""
	}

	keychain: token: string

	// FIXME: missing info: url

	code: dockerfile: """
        from alpine:3.9.4@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6
        run apk add -U --no-cache bash
        run apk add --no-cache rsync
        run apk add --no-cache yarn
        run apk add --no-cache curl jq
        run yarn global add netlify-cli
        """

	code: container: {
		alpinePackages: {
			yarn:  true
			curl:  true
			jq:    true
			rsync: true
		}
		extraCommands: [
			"yarn global add netlify-cli",
		]
	}

	code: onChange: #"""
        set -exu -o pipefail

        create_site() {
            # FIXME: This doesn't enable HTTPS on the site.
            url="https://api.netlify.com/api/v1/\#(settings.account)/sites"

            response=$(curl -f -H "Authorization: Bearer \#(keychain.token)" \
                        -X POST -H "Content-Type: application/json" \
                        $url \
                        -d '{"subdomain": "\#(settings.siteName)", "custom_domain": "\#(settings.domain)"}'
                    )
            [ $? -ne 0 ] && echo "create site failed" && exit 1

            echo $response | jq -r '.site_id'
        }

        site_id=$(curl -f -H "Authorization: Bearer \#(keychain.token)" \
                    https://api.netlify.com/api/v1/sites\?filter\=all | \
                    jq -r '.[] | select(.name=="\#(settings.siteName)") | .id' \
                )
        if [ -z "$site_id" ] ; then
            if [ '\#(strconv.FormatBool(settings.createSite))' != "true" ]; then
                echo "Site \#(settings.siteName) does not exist"
                exit 1
            fi
            site_id=$(create_site)
        fi
        netlify deploy \
            --dir="$(pwd)/input" \
            --auth='\#(keychain.token)' \
            --site="$site_id" \
            --message="Blocklayer 'netlify deploy'" \
            --prod \
        | tee tmp/stdout

        # enable SSL
        curl -i -X POST "https://api.netlify.com/api/v1/sites/${site_id}/ssl"

        <tmp/stdout sed -n -e 's/^Live URL:.*\(https:\/\/.*\)$/\1/p' > info/url
        """#
}

template: "yarn/build": {
	description: "yarn builder"

	input: description: "application code to build"

	output: description: "application build output"

	settings: {
		environment: [envVar=string]: string
		buildScript:    string | *"build"
		buildDirectory: string | *"build"
		writeEnvFile:   string | *false
		loadEnv:        bool | *true
	}

	code: dockerfile: """
        from alpine:3.9.4@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6
        run apk add -U --no-cache bash
        run apk add --no-cache rsync
        run apk add --no-cache yarn
        """

	code: container: {
		alpinePackages: {
			yarn:  true
			curl:  true
			jq:    true
			rsync: true
		}
		extraCommands: [
			"yarn global add netlify-cli",
		]
	}

	_codeFiles: "tmp/env": strings.Join([ "\(k)=\(v)" for k, v in settings.environment ], "\n")

	_codeArgs: {}
	{
		settings: loadEnv:  true
		_codeArgs: loadEnv: "1"
	} | {}
	{
		settings: writeEnvFile:  string
		_codeArgs: writeEnvFile: settings.writeEnvfile
	} | {}

	code: onChange: #"""
        set -x
        \#(strings.Join([ "cat >'\(path)' <<'EOF'\n\(data)\nEOF\n" for path, data in _codeFiles ], "\n"))
        \#(strings.Join([ "\(k)='\(v)'" for k, v in _codeArgs ], "\n"))

        export YARN_CACHE_FOLDER=cache/yarn
        mkdir -p tmp/src
        rsync -aH --delete input/ tmp/src/
        if [ "${writeEnvFile:-}" ]; then
            cp tmp/env tmp/src/"$writeEnvFile"
        fi
        if [ "${loadEnv:-}" ]; then
            export $(cat tmp/env | xargs)
        fi
        (
            cd tmp/src
            yarn install --network-timeout 1000000
            yarn run "\#(settings.buildScript)"
        )
        rsync -aH tmp/src/"\#(settings.buildDirectory)"/ output/
        """#
}
