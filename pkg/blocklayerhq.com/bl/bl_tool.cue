package myblconfig

import (
	"strings"
	"tool/cli"
	// "tool/exec"
)

command "ws-create": {
	description: "Create a new Blocklayer workspace"
}

command "ws-inspect": {
	description: "Show information about a workspace"
}

command "ws-list": {
	description: "List available workspaces"
}

command "ws-destroy": {
	description: "Destroy a workspace with all its staging environments and components"
}

command "env-create": {
	description: "Create a new staging environment in a workspace"
}

command "env-inspect": {
	description: "Show information about a staging environment"

	var: {
		envAddr: "acme.infralabs.io"
		_env: env[envAddr]
	}

	task print: cli.Print & {
		text: """
			address: \(var.envAddr)
			components:
			\(strings.Join([c.treeText for _, c in var._env.components], "\n"))
			input: <INSERT checksum here>
			output: <INSERT checksum here>
			settings:
			\(strings.Join(["\t" + c for c, _ in var._env.settings|{}], "\n"))
			info:
			\(strings.Join(["\t" + c for c, _ in var._env.info|{}], "\n"))
			staged changes:
				...
				<INSERT DIFF HERE>
				...
			last deploy ID: 42
			last deploy time: 2 hours ago
			"""
	}
}

command "env-destroy": {
	description: "Destroy a staging environment after removing all its components"
}

command "env-stage": {
	description: "Stage a change for deployment"
}

command "env-reset": {
	description: "Clear all staged changes from an environment"
}

command "env-deploy": {
	description: "Deploy all staged changes"
}


command "component-search": {
	description: "Search the catalog of available components"
}

command "component-install": {
	description: "Install a component in a staging environment"
}

command "component-inspect": {
	description: "Show information about a component"
}

command "component-remove": {
	description: "Removea component from a staging environment"
}

