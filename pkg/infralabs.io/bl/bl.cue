package bl

import (
	"strings"
	linuxContainer "infralabs.io/stdlib/linux/container"
)

Workspace :: {
	template: string
	domain: string
	env: string
	settings <Key>: _
	keychain <Key>: _

	// Fill in gates
	gates <Name>: Gate

	// Fill in address lookup table
	addresses: {
		for _, c in gates {
			"\(c.address)" "\(c.name)": c
		}
	}

	containers <Name>: linuxContainer.container
	// Configure a container to run each component
	containers: {
		for name, component in gates {
			"\(name)": linuxContainer.container
				// settings packages: component.install.packages & {bash: true}
			//}
		}
	}
}

Gate :: {
	name: string
	blueprint?: string
	address: string
	slug: strings.Replace(strings.Replace(address, ".", "-", -1), "_", "-", -1)
	description?: string

	// Gate-specific authentication secrets
	auth?: _
	settings <Name>: _
	info?: {
		<Name>: _
	}
	input: {
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
