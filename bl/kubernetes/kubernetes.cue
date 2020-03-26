package kubernetes

import (
	"list"
	"strings"
	"encoding/yaml"
)

// A kubernetes configuration, in a cue-optimized schema
// (easy to query and modify).
Config :: [kind=string]: [id=string]: _

// Load a configuration from the standard Kubernetes format.
// Input parts are typically unmarshalled from json or yaml.
Load :: {
	input: [..._]
	output: Config & {
		for _, p in input {
			if (p.metadata.name & string) != _|_ & (p.kind & string) != _|_  {
				"\(strings.ToLower(p.kind))": "\(p.metadata.name)": p
			}
			// Add ingress-specific transfromation
			// Add deployment-specific transfo
		}
	}
}

// Save a configuration to the standard Kubernetes format.
// The output can then be marshalled to json or yaml.
Save :: {
	input: Config
	output: [..._]

	output: list.FlattenN([
		[
			resource
			for name, resource in resourceGroup
		]
		for kind, resourceGroup in input
	], 1)
}


LoadYaml :: {
	rawYaml=input: string
	output: Config

	output: (Load & {
		// FIXME: this is a stopgap until yaml.Unmarshal supports multi-part
		input: [yaml.Unmarshal(rawPart) for rawPart in strings.Split(rawYaml, "---\n")]
	}).output
}

SaveYaml :: {
	config=input: Config
	output: string

	outputParts: (Save & {
		input: config
	}).output

	outputYamlParts: [yaml.Marshal(part) for part in outputParts]

	output: strings.Join(outputYamlParts, "---\n")
}

LoadYamlDirectory :: {
	files=input: [path=string]: string
	output: Config

	output: (Load & {
		input: [yaml.Unmarshal(contents) for _, contents in files]
	}).output
}
