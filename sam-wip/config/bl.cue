package main

import (
	"strings"
)

BlockList :: [string] : Block

BlockWalk :: {
	input:           BlockList
	myPrefix=prefix: [...string] | *[]
	output:          BlockList & {
		for childName, child in input {
			"\(strings.Join(prefix+[childName], "/"))": child
		}
		for childName, child in input {
			(BlockWalk & {input: child.block, prefix: myPrefix + [childName]}).output
		}
	}
}

Dockerfile :: {
	package: [pkg=string]: true
	package: bash:         true // always install bash
	package: jq:           true // always install jq
	extraCommand: [...string]

	installPackages = strings.Join([
		"run apk add -U --no-cache \(pkg)"
		for pkg, _ in package
	], "\n")
	runExtraCommands = strings.Join([
		"run \(cmd)"
		for cmd in extraCommand
	], "\n")

	alpineVersion: "latest"
	alpineDigest:  "sha256:ab00606a42621fb68f2ed6ad3c88be54397f981a7b70a79db3d1172b11c4367d"

	text: """
from alpine:\(alpineVersion)@\(alpineDigest)
\(installPackages)
\(runExtraCommands)
"""
}

// Schema of a block as specified by the user
Block :: {
	input:  bool | *false
	output: bool | *false

	connection: [...{
		from:     string | *"."
		fromDir?: string

		to:     string | *"."
		toDir?: string
	}]

	_blRuntime?: inputFrom?: {
		repository: string
		tag:        string
		digest:     string
	}

	// {
	//  // if there one connection from my input, switches the input to true
	//  connection: [..._, {from: "."}, ..._]
	//  input: true
	// } | {}

	settings: [key=string]: _
	keychain: [key=string]: _
	info: [key=string]:     _

	code?: {

		language: "bash"
		os:       "alpineLinux"
		package: [pkg=string]: true
		dir:          string | *"./code"
		extraCommand: [...string] | *[]

		// FIXME: deprecated fields below
		FIXMEdeprecated = [dockerfile, script, onChange]

		script:     string
		onChange:   """
#!/bin/bash


function settings() {
cmd="${1:-}"; shift 1 || true
case "$cmd" in
get)
filter="${1:-}"
jq -r ".$filter" < settings.json
;;
*)
echo >&2 no such command: settings $cmd
exit 1
;;
esac
}

function keychain() {
cmd="${1:-}"; shift 1 || true
case "$cmd" in
get)
filter="${1:-}"
jq -r ".$filter" < keychain.json
;;
*)
echo >&2 no such command: keychain $cmd
exit 1
;;
esac
}

\(script)
"""
		dockerfile: (Dockerfile & {
			package:      code.package
			extraCommand: code.extraCommand
		}).text
	}

	block: [name=string]: Block
} | {
	from:  string
	with?: Block
}

{
	Block
}

// block: [string]:    Block
// settings: [key=string]: _
