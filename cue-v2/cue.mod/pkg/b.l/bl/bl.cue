package bl

Secret :: {
	value: _
}

Directory :: {
	tag: string
	digest: string & =~ "^sha256:[0-9a-fA-F]{64}$"
} | {
	path: string
}

EmptyDirectory :: null

Subdirectory :: {
	input: Directory
	path: string
	subdirPath=path
	output: Directory

	{
		input: {
			tag: string
			digest: string
		}
		// FIXME: fill output with a llb task
		output: {
			tag: string
			digest: string
		}
	} | {
		input: path: string
		output: path: "\(input.path)/\(subdirPath)"
	}
}

BashScript :: {
	code: string
	environment: [key=string]: string
	os: package: [pkg=string]: bool
	workdir: *"/" | string
	mount: [path=string]: {
		{
			type: "cache"
		} |
		{
			type: "text" | "value"
			contents: _
		} | {
			"type": "copy"
			from: Directory
		}
	}
	rootfs: Directory
}
