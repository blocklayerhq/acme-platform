package bl

import (
	"strings"
	"encoding/json"
	"strconv"
)

engine: {
	version: [0, 0, 3]
	channel: "alpha"
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

	containers <Name>: LinuxAlpineContainer & {
		 settings systemPackages bash: true
		 settings systemPackages curl: true
	}
	containers: {
		for name, c in component {
			"\(name)": {
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

LinuxAlpineContainer :: {
	settings: {
		env? <Key>: string
		appDir : *"/app"|string
		appInstall: *[[]]|[...[...string]]
		appRun: [...string]
		alpineVersion: *[3]|[...int]
		alpineDigest?: string
		systemPackages <spkg>: true
		adhocPackages <ahpkg>: [...[...string]]
	}

	dockerfile: {
		out: """
			from alpine:\(alpineVersionWithDigest)
			# Install system packages
			\(systemPackages)
			# Install adhoc packages
			\(adhocPackages)
			# Copy app source into container
			COPY . \(settings.appDir)
			# Set environment for app install and run
			\(env)
			# Set workdir for app install and run
			WORKDIR \(settings.appDir)
			# Install app
			\(appInstall)
			# Configure run command
			\(appRunCmd)
			"""
		alpineVersion: strings.Join([strconv.FormatInt(n, 10) for n in settings.alpineVersion], ".")
		alpineDigest: ({dig:settings.alpineDigest, out:string} & ({dig:"", out:""}|{dig:_, out:"@\(dig)"})).out
		alpineVersionWithDigest: "\(alpineVersion)\(alpineDigest)"
		systemPackages: strings.Join(["RUN apk add -U --no-cache \(pkg)" for pkg, _ in settings.systemPackages], "\n")
		adhocPackages: strings.Join(["RUN \(json.Marshal(cmd))" for cmd in settings.adhocPackages], "\n")
		env: strings.Join(["ENV \(k)=\(v)" for k, v in settings.env|{}], "\n")
		appInstall: strings.Join(["RUN \(strings.Join(cmd, " "))" for cmd in settings.appInstall], "\n")
		appRunCmd: "CMD \(strings.Join(settings.appRun, " "))"
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
