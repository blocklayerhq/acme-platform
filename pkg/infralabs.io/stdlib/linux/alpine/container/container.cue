package container

import (
	"strconv"
	"strings"

	"encoding/json"
)

container: {
	slug: _ // Use the slug for default  image name
	input: _ // Use the input checksum for default image tag
	
	auth: _ // FIXME: provider-specific container registry credentials
	// FIXME generate auth provider, and auth provider schema
	
	info: {
		pushedTo: {
			fullName: settings._fullName
			digest: string
			fullNameWithDigest: "\(fullName)@\(digest)"
		}
	}
	
	settings: {
		env <Key>: string
		appDir? : *"/app"|string
		appInstall?: [...[...string]]
		appRun?: [...string]
		pushTo: {
			prefix: string
			name: *slug|string
			_fullName: "\(settings.prefix)/\(settings.name)"
			tag: *input.from|string
		}
		alpineVersion: *[3]|[...int]
		alpineDigest?: string
		systemPackages <spkg>: true
		adhocPackages <ahpkg>: [...[...string]]
	
			for pkg, _ in systemPackages {
				"\(pkg)": "RUN apk add -U --no-cache \(Pkg)"
			}
		}
	
		_dockerfile: {
			out: """
				from alpine:\(alpineVersionWithDigest)
				# Install system packages
				\(systemPackages)
				# Install adhoc packages
				\(adhocPackages)
				# Copy app source into container
				COPY . \(settings.appDir)
				# Set environment for app install and run
				\(strings.Join(["ENV " + k + "=" + v for k, v in settings.env], "\n"))
				# Set workdir for app install and run
				WORKDIR \(settings.appDir)
				# Install app
				\(appInstall)
				# Configure run command
				\(appRunCmd)
				"""
			alpineVersion: strings.Join([strconv.FormatInt(n, 10) for n in settings.alpineVersion], ".")
			alpineDigest: ({dig:settings.alpineDigest} & ({dig:"", out:""}|{dig:_, out:"@\(dig)"})).out
			alpineVersionWithDigest: "\(alpineVersion)\(alpineDigest)"
			systemPackages: strings.Join(["RUN apk add -U --no-cache \(pkg)" for pkg, _ in settings.systemPackages], "\n")
			adhocPackages: strings.Join(["RUN \(json.Marshal(cmd))" for cmd in settings.adhocPackages], "\n")
			env: strings.Join(["ENV \(k)=\(v)" for k, v in settings.env], "\n")
			appInstall: strings.Join(["RUN \(json.Marshal(cmd))" for cmd in settings.appInstall], "\n")
			appRunCmd: "CMD \(json.Marshal(settings.appRun))"
	}
	
	//  How to install this component
	install: {
		engine: [0, 0, 3]
		packages: {
			git: {}
			"docker-cli": {}
			"docker-compose": {}
			ssh: {}
			"aws-cli": {}
			"gcloud-cli": {}
			jq: {}
		}
		installCmd: "docker-buildx inspect '\(slug)' >/dev/null 2>&1 || docker-buildx create --name '\(slug)' --driver docker-container"
		removeCmd: "docker-buildx rm '\(slug)' || true"
	}
	
	assemble: """
		\(_scripts.docker_build_def)
		docker_build --load
		"""
	
	push: """
		\(_scripts.authenticate)
		\(_scripts.docker_build_def)
		docker_build --push
		# FIXME: set info.pushedTo
		"""
	
	_scripts docker_build_def: #"""
		# Common shell function for building
		# (re-used for assemble & push)
		docker_build() {
			local cacheArgs=(--cache-to type=local,dest=output/layers)
			if [ -e $layerCache/index.json ]; then
				cacheArgs+=(--cache-from type=local,src=output/layers)
			fi
			dockerfile=$(mktemp)
			cat >"$dockerfile" <<---EOF---
			\#(settings.dockerfile)
			---EOF---
			docker-buildx use '\#(slug)'
			docker-buildx build \
				"${cacheArgs[@]}" \
				-t '\#(settings.pushTo._fullName):\#(settings.pushTo.tag)' \
				-f "$dockerfile" \
				"$@" \
				input
			rm "$dockerfile"
		}
		"""#
	
	
	_scripts authenticate: #"""
		case '\#(settings.pushTo._fullName)' in
			gcr.io/*|*.gcr.io/*)
				gcloud -q auth activate-service-account --key-file=<(cat <<EOF\#n\#(json.Marshal(auth))\#nEOF\#n)
				gcloud -q config set project $(auth.project_id)
				gcloud -q auth configure-docker
			;;
			*.amazonaws.com/*)
				$(aws ecr get-login --no-include-email) \
					AWS_ACCESS_KEY_ID='\#(auth["access-key"])' \
					AWS_SECRET_ACCESS_KEY='\#(auth["secret-key"])' \
					AWS_DEFAULT_REGION='\#(auth.region)'
			;;
			*)
				docker login \
					--username=$(getauth username) \
					--password-stdin <<<$(getauth password) \
					"$registry"
			;;
		esac
		"""#
}
