package main

// Acme: acme clothing application

// App & {
//  hostname: "demo.acme.infralabs.io"
//  frontend: deploy: siteName: "acme-demo"
// }

import (
	"infralabs.io/acme/bl"
)

test: {
	foo: bl.BashScript & {
		code: """
					echo 1
					"""
	}
	bar: [
		bl.BashScript & {
			code: """
					echo 2
					"""
			dependsOn: test.foo
		},
		bl.BashScript & {
			code: foo.code
		},
		bl.BashScript & {
			code: """
					echo 4
					"""
		},
	]
}

frontend: buildScript: bl.BashScript & {
	code: """
			echo "$YARN_BUILD_SCRIPT"
			"""

	environment: YARN_BUILD_SCRIPT: "hello world"

	// workdir: "/src"
	// mount: "/src": {
	//  type: "readOnly"
	//  from: source
	// }
	// mount: "cache/yarn": {
	//  type: "cache"
	// }
	// if writeEnvFile != "" {
	//  mount: writeEnvFile: {
	//   type: "text"
	//   contents: strings.Join(["\(k)=\(v)" for k, v in environment], "\n")
	//  }
	// }

	os: package: {
		rsync: true
		yarn:  true
	}
}

backend: buildScript: bl.BashScript & {
	code: """
			env
			"""

	// workdir: "/src"
	// mount: "/src": {
	//  type: "readOnly"
	//  from: source
	// }
	// mount: "cache/yarn": {
	//  type: "cache"
	// }
	// if writeEnvFile != "" {
	//  mount: writeEnvFile: {
	//   type: "text"
	//   contents: strings.Join(["\(k)=\(v)" for k, v in environment], "\n")
	//  }
	// }

	os: package: {
		rsync: true
		yarn:  true
	}
}
