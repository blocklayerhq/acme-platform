package bl

import (
	"strings"

	linux_alpine_container "b.l/linux/alpine/container"
)

engine: {
	version: [0, 0, 3]
	channel: "alpha"

	action assemble: {

		for _, e in env {
			for _, c in e.component {
				"\(e.name)" "\(c.name)": {
					buildscript: """
						set -e
						# Assemble container for component '\(c.name)' of env '\(e.name)'
						(
							cd $(mktemp -d)
							echo "Building in $(pwd)"
							cat > entrypoint.sh <<'EOF'
						\(entrypoint)
						EOF
							cat > Dockerfile <<'EOF'
						\(container.dockerfile.out)
						EOF
							docker build -t b.l/\(e.name)/\(c.name) .
						)
						"""
					entrypoint: """
						#!/bin/bash

						set -eux

						cmd="${1:-}"; shift || true

						case "$cmd" in

							push)
								\(strings.Replace(c.action.push, "\n", "\n\t\t", -1))
							;;

							pull)
								\(strings.Replace(c.action.pull, "\n", "\n\t\t", -1))
							;;

							assemble)
								\(strings.Replace(c.action.assemble, "\n", "\n\t\t", -1))
							;;

							install)
								\(strings.Replace(c.action.install, "\n", "\n\t\t", -1))
							;;

							remove)
								\(strings.Replace(c.action.remove, "\n", "\n\t\t", -1))
							;;

							*)
								echo >&2 "Unsupported action: $cmd"
							;;

						esac

						# FIXME: entrypoint for '\(e.name)/\(c.name)'
						"""
					container: linux_alpine_container & {
						settings: {
							alpineVersion: [3, 9, 4]
							alpineDigest: "sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6"
							appDir: "/workspace"
							appRun: ["/entrypoint.sh"]
							appInstall: [
								["mkdir", "/input", "/output", "/info", "/cache"],
								["mv", "/workspace/entrypoint.sh", "/entrypoint.sh"],
								["chmod", "+x", "/entrypoint.sh"]
							]
							systemPackages: {
								bash: true // always install bash
								for vpkg, _ in c.container.packages {
									"\(vpkg)": true
								}
							}
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

   	container: {
   		engine?: *[0, 0, 3]|[...int]
   		packages? <Pkg>: true
   	}

   // 2. To be completed by component author
   action: {
	install: *""|string
   	remove: *""|string
   	pull: *""|string
   	assemble: *""|string
   	push: *""|string
   }
   info <K>: _
}
