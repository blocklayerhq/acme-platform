import (
	"strings"
)

Yarn :: {
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
			yarn: true
		}
	
		language: "bash"
		dir: "./yarn.code"
	
	}

	{
		settings: writeEnvfile: string
		code: extraFile: {
			"tmp/src/\(settings.writeEnvFile)": strings.Join([ "\(k)=\(v)" for k, v in settings.environment ], "\n")
		}
	} | *{}
}
