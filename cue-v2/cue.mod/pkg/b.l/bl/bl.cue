package bl

Secret :: {
	value: _
}

Directory:: {
	root?: Directory
	path: *"/" | string
	tag: string
	digest: string & =~ "^sha256:[0-9a-fA-F]{64}$"
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
