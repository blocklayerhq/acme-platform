import (
	"strings"

	acmeClothing "acme.infralabs.io/acme/clothing"
	mysqlDatabase "infralabs.io/stdlib/mysql/database"
	jsApp "infralabs.io/stdlib/js/app"
	jsContainer "infralabs.io/stdlib/js/container"
	netlifySite "infralabs.io/stdlib/netlify/site"
	kubernetesGke "infralabs.io/stdlib/kubernetes/gke"
	linuxContainer "infralabs.io/stdlib/linux/container"
)


/* PART 1: imported from infralabs.io/bl */

bl: { // Placeholder for `import ("infralabs.io/bl")`
Workspace :: {
	domain: string
	env: string
	keychain <Key>: _
	components <Name>: Component
	containers <Name>: linuxContainer.container
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
		packages <Pkg>: true
		installCmd?: string
		removeCmd?: string
		// YOU ARE HERE:
		// 1. Eval crash is caused by "Component &" below
		// 2. Flatten components: no more subcomponent nesting
		// 3. Replace app-specific components (like acme-clothing) with shareable workspace templates
		// 4. Rename components to gates
		// 5. gate <Name>: {
		//    	input: { from: LocalSource|PullSource, digest:_}
		//    	output: { to: LocalTarget|PushTarget, digest:_ }
		//	  }
		// 6. gate <Name> : {
		//		// fetch latest input from source (if remote: download; if local: recursively pull)
		//		action pull: Command 
		//		// process current input and produce new output (alt: "action process")
		//		action run Command 
		//		// send current output to target (if remote: upload; if local: recursively push)
		//		action push: Command
		//	  }
		// 7. RemoteSource :: { address: string }
		// 8. gate <Name> target: Hostname // 
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
	containers: {
		for name, component in components {
			"\(name)" settings packages: component.install.packages
		}
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

