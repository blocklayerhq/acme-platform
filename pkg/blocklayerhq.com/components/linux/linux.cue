package linux

import (
	"blocklayerhq.com/bl"
)

linux alpine AppContainer: {

	settings: {
		pushTo: {
			name: string
			tag: *"latest"|string
		}
		alpineVersion: *[3]|[...int]
		packages <Pkg>: {
			postInstall?: [[string]]
			installText: """
				RUN apk add -U --no-cache \(Pkg)
				\(strings.Join(["run " + strings.Join(cmd, " ") for cmd in Pkg.postInstall], "\n"))
				"""
		}
		packages npm: {
			postInstall: [["npm", "install", "-g", npmPkg] for npmPkg, _ in npm.install]
		}
		/*
		dockerfile: """
			from alpine:\(strings.Join([strconv.ParseInt(n, 10, strconv.IntSize) for n in settings.alpineVersion]), ".")
	
			# Install Alpine packages
			\(strings.Join([pkg.installText for pkg in packages], "\n"))
	
			# Copy app source into container
			COPY . \(appDir)
			WORKDIR \(appDir)
			\([strings.Join(["ENV " + k + "=" + v,
			\(appInstall)
			CMD \(cmd)
			"""
		*/
	}

	slug: _

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
		installCmd: #"""
			docker-buildx inspect '\#(slug)' >/dev/null 2>&1 \
		 	|| docker-buildx create --name '\#(slug)' --driver docker-container
		 	"""#
		removeCmd: "docker-buildx rm '\(slug)' || true"
	}

	assemble: """
			\(_docker_build_def)
			docker_build --load
		"""

	push: """
			\(_docker_build_ref)
			docker_build --push
		"""

	_docker_build_def: #"""
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
				-t '\#(settings.pushTo)' \
				-f "$dockerfile" \
				"$@" \
				input
			rm "$dockerfile"
		}
		"""#

	

}
