package container

import (
	"strconv"
	"strings"
	"encoding/json"
)

// A simple Alpine Linux application container

settings: {
	env? <Key>: string
	appDir : *"/app"|string
	appInstall?: [...[...string]]
	appRun: [...string]
	alpineVersion: *[3]|[...int]
	alpineDigest?: string
	systemPackages <spkg>: true
	adhocPackages <ahpkg>: [...[...string]]
	buildLabel?: string
	copy: *false|bool
}

dockerfile: {
	out: """
		from alpine:\(alpineVersionWithDigest)\(buildLabel)
		# Install system packages
		\(systemPackages)
		# Install adhoc packages
		\(adhocPackages)
		# Copy app source into container
		\(copy)
		# Set environment for app install and run
		\(env)
		# Set workdir for app install and run
		WORKDIR \(settings.appDir)
		# Install app
		\(appInstall)
		# Configure entrypoint
		\(entrypoint)
		"""

	copy: *""|string
	if settings.copy {
		copy: "COPY . \(settings.appDir)"
	}
	buildLabel: *""|string
	if settings.buildLabel != "" {
		buildLabel: " as \(settings.buildLabel)"
	}
	alpineVersion: strings.Join([strconv.FormatInt(n, 10) for n in settings.alpineVersion], ".")
	alpineDigest: ({dig:settings.alpineDigest, out:string} & ({dig:"", out:""}|{dig:_, out:"@\(dig)"})).out
	alpineVersionWithDigest: "\(alpineVersion)\(alpineDigest)"
	systemPackages: strings.Join(["RUN apk add -U --no-cache \(pkg)" for pkg, _ in settings.systemPackages], "\n")
	adhocPackages: strings.Join(["RUN \(json.Marshal(cmd))" for cmd in settings.adhocPackages], "\n")
	env: strings.Join(["ENV \(k)=\(v)" for k, v in settings.env|{}], "\n")
	appInstall: strings.Join(["RUN \(json.Marshal(cmd))" for cmd in settings.appInstall], "\n")
	entrypoint: "ENTRYPOINT \(json.Marshal(settings.appRun))"
}
