package bl

Component :: {
	address: string
	slug: strings.Replace(slug, "-", "_", -1)

	settings <Key>: _
	info <Key>: _
	input?: {
		from: Component
		fromDir: *"/"|string
		checkskum: *""|string
	}
	parentAddress=address
	subcomponents <Name>: Component & {
		address: *parentAddress|string
	}

	install: {
		engine: *[0, 0, 3] | [...int]
		packages <Pkg>: {
			installText: """

				"""
		}
	}
	remove? : string
	pull?: string
	assemble?: string
	push?: string
}

component <Name>: Component

env <Address>: Component & {
	address: Address
}

