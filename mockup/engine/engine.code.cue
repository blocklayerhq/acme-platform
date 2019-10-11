package bl

import (
	"strings"

	linux_alpine_container "b.l/linux/alpine/container"
)

engine: {
	version: [0, 0, 3]
	channel: "alpha"

	cache: "./data"

	action assemble: {

		for _, e in env {
			for _, c in e.component {
				"\(e.name)" "\(c.name)": {
					dockerfile: """
						# syntax=docker/dockerfile:experimental@sha256:9022e911101f01b2854c7a4b2c77f524b998891941da55208e71c0335e6e82c3
						\(container.dockerfile.out)

						RUN --mount=type=cache,target=/workspace/cache /entrypoint.sh pull
						RUN --mount=type=cache,target=/workspace/cache /entrypoint.sh assemble

						FROM scratch AS output
						COPY --from=component /\(container.settings.appDir)/input /input
						COPY --from=component /\(container.settings.appDir)/output /output
						COPY --from=component /\(container.settings.appDir)/info /info
						COPY --from=component /\(container.settings.appDir)/cache /cache
						"""

					dataPath: "./env/\(e.name)/data/component/\(c.name)"
					buildscript: """
						set -e
						# Assemble container for component '\(c.name)' of env '\(e.name)'
						src="$(mktemp -d)"
						cat > "$src/entrypoint.sh" <<'EOF'
						\(entrypoint)
						EOF
						cat > "$src/Dockerfile" <<'EOF'
						\(dockerfile)
						EOF

						# Hack to initialize ./data if it doesn't exist
						# (otherwise, docker-buildx complains)
						if [ ! -d ./data ]; then
							docker-buildx build --cache-to type=local,dest=\(cache) - <<<"from scratch" 2>/dev/null >/dev/null
						fi
						docker-buildx build --progress=plain --output type=local,dest='\(dataPath)' --cache-from type=local,src='\(cache)' --cache-to type=local,dest='\(cache)' "$src"
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
							buildLabel: "component" // Base label for multi-stage build
							alpineVersion: [3, 9, 4]
							alpineDigest: "sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6"
							appDir: "/workspace"
							appRun: ["/entrypoint.sh"]
							appInstall: [
								["mkdir", "input", "output", "info", "cache"],
								["mv", "entrypoint.sh", "/entrypoint.sh"],
								["chmod", "+x", "/entrypoint.sh"]
							] + [
								["touch", "info/\(key)"] for key, _ in c.info
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
