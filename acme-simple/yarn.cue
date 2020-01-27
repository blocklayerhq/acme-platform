import (
	"strings"
)

Yarn :: Block & {
	settings: {
		environment: [envVar=string]: string
		buildScript:    string | *"build"
		buildDirectory: string | *"build"
		writeEnvFile:   string | *false
		loadEnv:        bool | *true
	}

	// Javascript source code to build
	input: true
	// Fully built javascript app
	output: true

	code: {
		os: "alpineLinux"
		package: {
			rsync: true
			yarn:  true
		}

		language: "bash"
		dir:      "./yarn.code"

		script: #"""
			export YARN_CACHE_FOLDER=cache/yarn
			mkdir -p tmp/src
			rsync -aH input/ tmp/src/

			if [ "$(settings get loadEnv)" = 1 ]; then
				export $(cat tmp/env | xargs)
			fi
			buildScript="$(settings get buildScript)"
			(
				cd tmp/src
				yarn install --network-timeout 1000000
				yarn run "$buildScript"
			)
			rsync -aH tmp/src/"$(settings get buildDirectory)"/ output/
			"""#
	}

	{
		settings: writeEnvfile: string
		code: extraFile: {
			"tmp/src/\(settings.writeEnvFile)": strings.Join([ "\(k)=\(v)" for k, v in settings.environment ], "\n")
		}
	} | *{}
}
