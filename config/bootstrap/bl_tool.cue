package main

import (
	"strings"
	"tool/cli"
)

BulkPushAcme :: BulkPush & {
	domain: "acme.infralabs.io"
	envName: "devInfra"
	draftName: "acme-bootstrap"
}

BulkPush :: {
	envName: string
	domain: string
	draftName: string

	pushCommands: {
		for key, value in bootstrap[envName] {
			if (value & string) != _|_ {
				"\(key)": #"""
					bl push \
						--draft '\#(draftName)' \
						'\#(domain)' \
						--target 'env.\#(envName).input.\#(key)' \
						--kind text \
						'\#(value)'
					"""#
			}
			if (value & secret) != _|_ {
				"\(key)": #"""
					bl push \
						--draft '\#(draftName)' \
						'\#(domain)' \
						--target 'env.\#(envName).input.\#(key).value' \
						--kind text \
						'\#(value.value)'
					"""#
			}
		}
	}

	command: """
		(
			set -o errexit -o xtrace
			bl draft rm '\(draftName)' 2>/dev/null || true
			bl draft init '\(draftName)'
			\(strings.Join([cmd for _, cmd in pushCommands], "\n"))
		)
		"""
}

RunLocal :: {
	envName: string
	output: string | *"localhost:5001/bl-debug-output"

	inputFlags: {
		for key, value in env[envName].input {
			if (value & string) != _|_ {
				"\(key)": "-v 'env.\(envName).input.\(key)=\(value)'"
			}
			if (value & secret) != _|_ {
				"\(key)": "-v 'env.\(envName).input.\(key).value=\(value.value)'"
			}
		}
	}
	command: #"""
		(
			set -o xtrace -o errexit
			bl-runtime run -t '\#(output)' \
			\#(strings.Join(["	\(flags)" for _, flags in inputFlags], "\\\n"))
		)
		"""#
}

command: bootstrap: cli.Print & {
	text: BulkPushAcme.command
}

command: runLocal: cli.Print & {
	run: RunLocal & {
		envName: "devInfra"
	}

	// text: strings.Join(["\(k)=\(v)" for k, v in run.inputFlags], "\n")
	text: run.command
}
