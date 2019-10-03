import (
	"strings"

	"acme.infralabs.io/acme/clothing"
	"infralabs.io/stdlib/linux/alpine/container"
)


/* PART 1: imported from infralabs.io/bl */

bl: { // Placeholder for `import ("infralabs.io/bl")`
Workspace :: {
	domain: string
	name: string
	keychain <Key>: _
	components <Name>: Component
}

Component :: {
	name: string
	address <Name>: Address
	description?: string

	// Component-specific authentication secrets
	auth: _
	settings <Name>: _
	info: {
		<Name>: _
	}
	input?: {
		from: TreeChecksum
		fromDir: *"/"|string
	}
	output: TreeChecksum
	// Sub-components
	components <Name>: _
	install: {
		engine: *[0, 0, 3] | [...int]
		packages <Pkg>: {
			installText: """

				"""
		}
		installCmd?: string
		removeCmd?: string
	}
	pull?: string
	assemble?: string
	push?: string
	...
}

TreeChecksum :: string & =~"^sha256:[0-9a-fA-F]{64}$"


Address: {
	description: string
	// FIXME: this is a crude approximation of a regexp for allowed hostnames,
	// not the real thing
	host: string & =~#"^[a-zA-Z0-9\-\.]+$"#
	slug: strings.Replace(strings.Replace(host, ".", "-", -1), "_", "-", -1)
}


workspace <Addr> <Env>: bl.Workspace & {
	address: *Addr|Address
	env: Env
	name: Name
	components <C>: bl.Component
}

address <Name>: bl.Address
}



/* PART 2: APP-SPECIFIC GENERATED GLUE BELOW */

workspace "acme.infralabs.io" prod components: {
	"acme-clothing": clothing & {
		components: {
			"api/container": container & {...}
		}
	}
}

