package container

import (
	alpineLinuxContainer "infralabs.io/stdlib/linux/alpine/container"
)

container: alpineLinuxContainer.container & {
	settings: {
		packages <vpkg>: true
		alpineVersion: [3, 9, 4]
		alpineDigest: "sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6"
		appDir: "/workspace"
		appRun: ["/entrypoint.sh"]
		appInstall: [
			["mkdir", "/input", "/output", "/info", "/cache"]
			// FIXME: inject entrypoint script
		]

		// Convert component virtual packages to apk packages + hacks
		systemPackages: {
			for vpkg, _ in settings.packages {
				for syspkg, cfg in vpackage[vpkg].system|{"\(vpkg)": true} {
					"\(syspkg)": true
				}
			}
		}
		adhocPackages: {
			for vpkg, _ in settings.packages {
				"\(vpkg)": "\(vpackage[vpkg].adhoc|[[]])"
			}
		}
	}
}


vpackage <vpkg>: {
	version?: string
	system? <spkg>: true
	adhoc?: [...[...string]]
}


vpackage "netlify-cli": {
	system yarn: true
	adhoc: [["yarn", "global", "add", "netlify-cli"]]
}

vpackage "aws-cli": {
	system: {
		python: true
		coreutils: true
		"py-pip": true
	}
	adhoc: [["pip", "install", "awscli"]]
}

vpackage "gcloud-cli": {
	version:"248.0.0-linux-x86_64"
	system: {
		python: true
		coreutiles: true
		curl: true
	}
	adhoc: [["sh", "-c", "curl '\(url)' | tar -C /var -zx"]]
	urlBase="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads"
	url="\(urlBase)/google-cloud-sdk-\(version).tar.gz"
}

vpackage "docker-compose": {
	system: {
		"py-pip": true
		"gcc": true
		"python2-dev": true
		"python3-dev": true
		"libffi-dev": true
		"musl-dev": true
		"openssl-dev": true
		"make": true
	}
	adhoc: [["pip", "install", "docker-compose"]]
}

vpackage "shopify-kubernetes-deploy": {
	system: {
		ruby: true
		"ruby-dev": true
		"g++": true
		"make": true
	}
	adhoc: [
		["gem", "install", "--no-ri", "kubernetes-deploy"],
		["gem", "install", "--no-rdoc", "bigdecimal"]
		// FIXME: apk del ruby-dev g++ make  (for layer optimization)
	]
}

vpackage kubectl: {
	version: "v1.16.1"
	system curl: true
	adhoc: [
		["curl", "-L", "-o", binPath, binUrl],
		["chmod", "+x", binPath]
		// FIXME: apk del curl (to optimize layers)
	]

	// Internal helper variables
	versionUrl = "\(urlBase)/stable.txt"
	urlBase = "https://storage.googleapis.com/kubernetes-release/release"
	binUrl = "\(urlBase)/\(version)/bin/linux/amd64/kubectl"
	binPath = "/usr/local/bin/kubectl"
}

vpackage terraform: {
	version: "0.12.3"

	system curl: true
	adhoc: [
		["curl", "-L", binUrl, "-o", "/tmp/tf.zip"],
		["unzip", "/tmp/tf.zip"],
		["cp", "/tmp/terraform", binPath],
		// + a hack to pre-install the mysql plugin for terraform
		// Note: super annoying that terraform doesn't let me do this
		["mkdir", "-p", "/var/terraform/plugins"],
		["sh", "-c", #"cat 'provider "mysql" { endpoint = "dtc" }' > /var/terraform/fake.tf"#],
		["sh", "-c", "cd /var/terraform && terraform init --input=false"]
	]	

	// Internal helper variables
	baseUrl = "https://releases.hashicorp.com/terraform"
	binUrl = "\(baseUrl)/\(version)/terraform_\(version)_linux_amd64.zip"
	binPath = "/usr/local/bin/terraform"
}

