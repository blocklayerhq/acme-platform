// Schema of a block as specified by the user
Block :: {

	fromTemplate: string | *""

	description: string | *""

	input: *false | {
		description: *"" | string
		// FIXME: specify if it can be empty or not

		from:          string | *""
		fromDirectory: string | *""
	}
	output: *false | {
		description: string | *""
	}

	settings: [key=string]: _
	keychain: [key=string]: _
	info: [key=string]:     _

	// (experimental & disabled)
	code: container: _

	code: {
		onChange: ShellScript
		// future entrypoints can be added here
		dockerfile: string

		ShellScript :: string
	} | *{
		onChange:   ""
		dockerfile: ""
	}

	block: [name=string]: Block
}

// experimental & disabled
BlockContainer :: {

	block: Block

	alpineVersion: "3.9.4"
	alpineDigest:  "sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6"
	alpinePackages: [pkg=string]: true
	extraCommands: [...string]
	dockerfile: #"""
		from alpine:\(alpineVersion)@\(alpineDigest)
		run apk update
		run apk add --no-cache bash
		\(strings.Join(["run apk add --no-cache '\(pkg)'" for pkg, _ in alpinePackages], "\n")
		\(strings.Join(["run \(cmd)" for cmd in extraCommands], "\n")
		"""#
}

Template :: Block

UserConfig :: {
	template: [string]: Template
	block: [string]:    Block
}

// BLOCKS:

block: [string]:    Block
template: [string]: Block
