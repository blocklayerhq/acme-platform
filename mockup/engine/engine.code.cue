package bl

import (
	"strings"

	linux_alpine_container "b.l/linux/alpine/container"
)

engine: {
	version: [0, 0, 3]
	channel: "alpha"

	container <envName> <componentName>: linux_alpine_container & {
		settings systemPackages: {
			bash: true
			curl: true
		}
	}
	container: {
		for envName, _ in env {
			for componentName, _ in env[envName].component {
				"\(envName)" "\(componentName)": {
					settings: {
						alpineVersion: [3, 9, 4]
						alpineDigest: "sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6"
						appDir: "/workspace"
						appRun: ["/entrypoint.sh"]
						appInstall: [
							["mkdir", "/input", "/output", "/info", "/cache"]
							// FIXME: inject entrypoint script
						]
						systemPackages: {
							 "openssh-client": true
							 "git": true
						}
					}
				}
			}
		}
	}
}

env <envName>: {
	name: envName
	target: string
	TARGET=target, component <componentName> target: *TARGET|string
	settings <K>: _
	keychain <K>: _

	component <componentName>: Component & {
		// Helpers
		name: componentName
	}
}

Component :: {
   name: _
   target: _
   slug: strings.Replace(strings.Replace(target, ".", "-", -1), "_", "-", -1)

   // 1. To be completed by env operator
   blueprint?: string
   settings: {...}
   auth?: _
   input?: {
   	from: string
   	fromDir: string
   	toDir: string
   }
   remotes: {
   	pullFrom?: _
   	pushTo?: _
   }

   // 2. To be completed by component author
   actions: {
   	install?: {
   		engine?: *[0, 0, 3]|[...int]
   		packages? <Pkg>: true
   	}
   	remove?: string
   	pull?: string
   	assemble?: string
   	push?: string
   }
   info <K>: _
}
