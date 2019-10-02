package bl

import (
	"strings"
)

Component :: {
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
	...
}

component <Name>: Component

env <Address>: Component & {
	address: Address
}

