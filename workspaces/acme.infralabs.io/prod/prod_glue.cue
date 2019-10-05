import (
	"strings"

	acmeClothing "acme.infralabs.io/acme/clothing"
	mysqlDatabase "infralabs.io/stdlib/mysql/database"
	gitRepo "infralabs.io/stdlib/git/repo"
	jsApp "infralabs.io/stdlib/js/app"
	netlifySite "infralabs.io/stdlib/netlify/site"
	kubernetesGke "infralabs.io/stdlib/kubernetes/gke"
	linuxContainer "infralabs.io/stdlib/linux/container"
	linuxAlpineContainer "infralabs.io/stdlib/linux/alpine/container"
)


/* PART 1: imported from infralabs.io/bl */

bl: { // Placeholder for `import ("infralabs.io/bl")`
Workspace :: {
	template: string
	domain: string
	env: string
	settings <Key>: _
	keychain <Key>: _

	// Fill in gates
	gates <Name>: {
		name: Name
		address: *domain|string
	}

	// Fill in address lookup table
	addresses <T> <C>: Gate
	addresses: {
		for _, c in gates {
			"\(c.address)" "\(c.name)": c
		}
	}

	// Configure a container to run each component
	containers <Name>: linuxContainer.container
	containers: {
		for name, component in gates {
			"\(name)" settings packages: component.install.packages
		}
	}
}

Gate :: {
	name: string
	blueprint: string
	address: Hostname
	slug: strings.Replace(strings.Replace(address, ".", "-", -1), "_", "-", -1)
	description?: string

	// Gate-specific authentication secrets
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
	install: {
		engine: *[0, 0, 3] | [...int]
		packages <Pkg>: true
		installCmd?: string
		removeCmd?: string
		// YOU ARE HERE:
		// 1. [DONE] Eval crash is caused by "Gate &" below
		// 2. [...] Flatten gates: no more subcomponent nesting
		// 3. [...] Replace app-specific gates (like acme-clothing) with shareable workspace templates
		// 4. Rename gates to gates
		// 5. gate <Name>: {
		//    	input: { from: LocalSource|PullSource, digest:_}
		//    	output: { to: LocalTarget|PushTarget, digest:_ }
		//	  }
		// 6. gate <Name> : {
		//		// fetch latest input from source (if remote: download; if local: recursively pull)
		//		action pull: Command 
		//		// process current input and produce new output (alt: "action process")
		//		action run Command 
		//		// send current output to pushTarget (if remote: upload; if local: recursively push)
		//		action push: Command
		//	  }
		// 7. RemoteSource :: { address: string }
		// 8. gate <Name> address: Hostname // 
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
}


/* PART 3: APP-SPECIFIC GENERATED GLUE */

workspace "acme.infralabs.io" prod: acmeClothing.clothing & {
	gates: {
		"monorepo": bl.Gate & gitRepo.repo
		"api/app": bl.Gate & jsApp.app
		"api/container": bl.Gate & linuxAlpineContainer.container
		"api/db": bl.Gate & mysqlDatabase.database
		"api/kube": bl.Gate & kubernetesGke.gke
		"web/netlify": bl.Gate & netlifySite.site
		"web/app": bl.Gate & jsApp.app
	}
}

