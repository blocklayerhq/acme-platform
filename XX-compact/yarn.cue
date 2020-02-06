import (
	"strings"
)

Yarn :: {
	// Javascript source code to build
	Input: {
		optional: false
		pipeline: [
			{
				action: "script"
				os: package: {
					rsync: true
					yarn: true
				}
				code: "./yarn.code"
			}
		]
	}

	environment: [envVar=string]: string
	buildScript:    string | *"build"
	buildDirectory: string | *"build"
	loadEnv:        bool | *true
	writeEnvFile:   string | *false
	{
		writeEnvfile: string
		code: extraFile: {
			"tmp/src/\(writeEnvFile)": strings.Join([ "\(k)=\(v)" for k, v in environment ], "\n")
		}
	} | *{}
}
