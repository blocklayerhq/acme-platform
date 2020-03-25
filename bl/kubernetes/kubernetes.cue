package kubernetes

import (
	"strings"
	"encoding/yaml"
)

ConfigFile :: {
	YAMLFile
	YAMLConfig

	contents: string
}

Config :: [kind=string]: [id=string]: _

// FIXME: rename to parseYAMLConfig,
// use like a function, expose resource
YAMLConfig :: {
	// List of parts parsed from yaml
	parts: [..._]

	resource: Config & {
		for _, p in parts {
			if (p.metadata.name & string) != _|_ & (p.kind & string) != _|_  {
				"\(strings.ToLower(p.kind))": "\(p.metadata.name)": p
			}
			// Add ingress-specific transfromation
			// Add deployment-specific transfo
		}
	}
}

// A directory of yaml files.
// FIXME: for now, yaml contents must be inlined here statically.
// FIXME: later, implement dynamic loading so that yaml config can be upoloaded as input.
YAMLDirectory :: {
	// Raw YAML files, organized by path
	file: [path=string]: string
	parts: [yaml.Unmarshal(contents) for _, contents in file]
}

YAMLFile :: {
	contents: string

	// FIXME: this is a stopgap until yaml.Unmarshal supports multi-part
	rawParts: strings.Split(contents, "---\n")
	parts: [yaml.Unmarshal(rawPart) for rawPart in rawParts]
}
