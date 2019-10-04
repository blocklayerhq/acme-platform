import (
	// "strings"
	// "tool/cli"
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

