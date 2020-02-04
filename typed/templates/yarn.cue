package templates

import (
	"infralabs.io/acme/bl"
	"strings"
)

Yarn :: {
	source: bl.Directory
	build:  bl.Directory

	environment: [envVar=string]: string
	buildScript:    string | *"build"
	buildDirectory: string | *"build"
	loadEnv:        bool | *true
	writeEnvFile:   string | *false
	{
		writeEnvfile: string
		code: extraFile: "tmp/src/\(writeEnvFile)": strings.Join([ "\(k)=\(v)" for k, v in environment ], "\n")
	} | *{}

	// Javascript source code to build
	script: bl.BashScript & {
		input: source
		os: package: {
			rsync: true
			yarn:  true
		}
		code: "./yarn.code"
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
}
