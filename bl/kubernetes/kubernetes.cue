package kubernetes

import (
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

	// FIXME
}

LoadYaml :: {
	rawYaml=input: string
	output: Config

	output: (Load & {
		// FIXME: this is a stopgap until yaml.Unmarshal supports multi-part
		input: [yaml.Unmarshal(rawPart) for rawPart in strings.Split(rawYaml, "---\n")]
	}).output
}

LoadYamlDirectory :: {
	files=input: [path=string]: string
	output: Config

	output: (Load & {
		input: [yaml.Unmarshal(contents) for _, contents in files]
	}).output
}
