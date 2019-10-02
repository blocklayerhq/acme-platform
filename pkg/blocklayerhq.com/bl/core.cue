package bl

import (
	"strings"
)

Component :: {
	name: string
	address: string
	slug: strings.Replace(address, "-", "_", -1)
	description: string

	settings <Key>: _
	info <Key>: _
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

// FIXME: is this applied?
component <Name>: Component & { foo: int }

env <Address>: Component & {
	address: Address
}

