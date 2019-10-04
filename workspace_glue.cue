import (
	"strings"

	acmeClothing "acme.infralabs.io/acme/clothing"
	mysqlDatabase "infralabs.io/stdlib/mysql/database"
	jsApp "infralabs.io/stdlib/js/app"
	jsContainer "infralabs.io/stdlib/js/container"
	netlifySite "infralabs.io/stdlib/netlify/site"
	kubernetesGke "infralabs.io/stdlib/kubernetes/gke"
)


/* PART 1: imported from infralabs.io/bl */

bl: { // Placeholder for `import ("infralabs.io/bl")`
Workspace :: {
	domain: string
	env: string
	keychain <Key>: _
	components <Name>: Component
}

Component :: {
	name: string
	blueprint: string
	address: Hostname
	slug: strings.Replace(strings.Replace(address, ".", "-", -1), "_", "-", -1)
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
	components <Name>: {
		name: Name
		...
	}
	install: {
		engine: *[0, 0, 3] | [...int]
		packages <Pkg>: true|{<SubPkg>: true} // Copied from `alpine/linux/container`. 
		installCmd?: string
		removeCmd?: string
	}
	pull?: string
	assemble?: string
	push?: string
}

TreeChecksum :: string & =~"^sha256:[0-9a-fA-F]{64}$"
Hostname: string & =~#"^[a-zA-Z0-9\-\.]+$"# // FIXME: approximation of hostname regexp

} // end of placeholder for `import ("infralabs.io/bl")`


/* PART 2: COMMON GLUE */

workspace <Domain> <Env>: bl.Workspace & {
	domain: *Domain|Hostname
	env: Env
	components <C>: bl.Component & {
		name: C
		address: *Domain|Hostname
	}
}



/* PART 3: APP-SPECIFIC GENERATED GLUE */

workspace "acme.infralabs.io" prod components: {
	"acme-clothing": acmeClothing.clothing & {
		components: {
			"api/container": bl.Component & jsContainer.container
			"api/db": bl.Component & mysqlDatabase.database
			"api/kube": bl.Component & kubernetesGke.gke
			"web/netlify": bl.Component & netlifySite.site
			"web/app": bl.Component & jsApp.app
		}
	}
}

