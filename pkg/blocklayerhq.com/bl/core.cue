package bl

import (
	"strings"
)

Workspace :: {
	name: string
	keychain <Key>: _
}

Component :: {
	name: string
	address: string
	slug: strings.Replace(address, "-", "_", -1)
	description?: string

	// Component-specific authentication secrets
	auth: _
	settings <Name>: _
	info <Name>: _
	input?: {
		from: Component
		fromDir: *"/"|string
		checkskum: *""|string
	}
	_address=address
	subcomponents <Name>: /*Component & */ { // FIXME infinite recursion
		address: *_address|string
		...
	}
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

	treeDepth: int|*1
	_treeDepth: treeDepth
	treeText: """
		\("\t"*treeDepth)\(name):
		"""
		/*
		\(strings.Join([(sub & {treeDepth:_treeDepth}).treeText for _, sub in subcomponents]))
		"""
		*/
	...
}
