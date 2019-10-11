package bl

import (
	"strings"
	"encoding/base64"

	linux_alpine_container "b.l/linux/alpine/container"
)

engine: {
	version: [0, 0, 3]
	channel: "alpha"
	cache: "./data"

	settings: {
		stateRepo: string
	}
}


for _, e in env {
	engine action env "\(e.name)" stage: {

		statedir: ".bl/state"
		imageName: "\(engine.settings.stateRepo):\(e.name)"

		script: {
			out: """
				#!/bin/bash

				dockerfile="$(mktemp)"
				cat >"$dockerfile" <<'EOF'
				\(dockerfile)
				EOF
				echo "Building env '\(e.name)' with input=. and dockerfile=$dockerfile"
				\(initState)
				\(buildx) \(cacheFrom) \(componentCacheFlags) --push -t '\(imageName)' -f "$dockerfile" .
				"""

			initState: """
				# Hack to initialize ./data if it doesn't exist
				# (otherwise, docker-buildx complains)
				if [ ! -d '\(statedir)' ]; then
					echo "Empty state directory. Initializing \(statedir)"
					\(buildx) - <<<'from scratch' >/dev/null 2>&1
				fi

				# If there is no env state (image \(imageName)), create it
				docker-buildx imagetools inspect '\(imageName)' >/dev/null 2>&1 || {
					echo "Empty env state. Initializing \(imageName)"
					\(buildx) --push -t '\(imageName)' - <<<'from scratch' >/dev/null 2>&1
				}
				"""
			cacheFrom: "--cache-from=type=local,src='\(statedir)'"
			cacheTo: "--cache-to=type=local,dest='\(statedir)'"
			buildx: "docker-buildx build --progress=plain \(cacheTo)" 
			componentCacheFlags=strings.Join([action.component[e.name][c.name].stage.cacheFlag for _, c in e.component], " ")
		}

		forEach = {
			component <c>: string
			for c, _ in e.component { component "\(c)": string }
			out: strings.Join([line for _, line in component], "\n") 
		}

		dockerfile: """
			# syntax=docker/dockerfile:experimental@sha256:9022e911101f01b2854c7a4b2c77f524b998891941da55208e71c0335e6e82c3
			# Load env state from previous run
			FROM \(imageName) AS env

			# Initialize state directory if it's empty
			\((forEach & {
				component <c>: #"""
					RUN \
						--mount=type=bind,from=busybox,source=/bin/mkdir,target=/bin/mkdir \
						["/bin/mkdir", "-p", "/component/\#(c)"]
					"""#
			}).out)

			# Run 'stage' entrypoint of each bot
			# FIXME: connect component dependency graph with 'COPY --from='
			\(strings.Join([
				action.component[e.name][c.name].stage.dockerfile
				for _, c in e.component
			], "\n"))


			FROM scratch AS output
			\(strings.Join([
				"COPY --from=\(engine.container[e.name][c.name].settings.buildLabel) /workspace /component/\(c.name)"
				for _, c in e.component
			], "\n"))
			"""
	}


	for _, c in e.component {
		engine container "\(e.name)" "\(c.name)": linux_alpine_container & {
			settings: {
				buildLabel: "component_\(e.name)_\(c.name)"
				alpineVersion: [3, 9, 4]
				alpineDigest: "sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6"
				appDir: "/workspace"
				appRun: ["/entrypoint.sh"]
				appInstall: [
					["mkdir", "input", "output", "info", "cache"],
					["bash", "-c", "base64 -d> /entrypoint.sh <<<'\(base64.Encode(null, entrypoint.out))'"],
					["chmod", "+x", "/entrypoint.sh"],
					["touch"] + ["info/\(key)" for key, _ in c.info]
				]
				systemPackages: {
					bash: true
					for vpkg, _ in c.container.packages {
						"\(vpkg)": true
					}
				}
			}

			entrypoint = {
				out: """
					#!/bin/bash

					set -eux
					cmd="${1:-}"; shift || true
					case "$cmd" in
						\(strings.Join(actionSnippets, "\n"))
						*)
							echo >&2 "Unsupported action: $cmd"
						;;
					esac
					"""

				actionSnippets: ["""
					\(action))
						\(strings.Replace(snippet, "\n", "\n\t\t", -1))
					;;
					"""
					for action, snippet in c.action
				]

			}
		}

		engine action component "\(e.name)" "\(c.name)":  {
			stage cache: true
			pull cache: false
			push cache: false
			install cache: false
			remove cache: false

			<actionName>: {
				cache: bool|*true
				cacheKey: "cache_key_\(c.name)"
				cacheFlag: *""|string
				if !cache {
					cacheFlag: "--arg \(cacheKey)=$(date +%s)-$RANDOM"
				}

				dockerfile: """
					\(engine.container[e.name][c.name].dockerfile.out)

					# Hook up inputs (FIXME)
					COPY --from=env /component/\(c.name) /workspace

					# Hook up keychain (FIXME)

					# Set this to a random value at runtime to disable cache
					ARG \(cacheKey)=42
					# Run the 'stage' entrypoint of component '\(c.name)' in env '\(e.name)'
					RUN --mount=type=cache,target=/workspace/cache /entrypoint.sh stage
					"""
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
   	stage: *""|string
   	push: *""|string
   }
   info <K>: _
}
