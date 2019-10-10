package bl

import (
	"strings"
	"tool/exec"
	"tool/file"
)

command codegen: {
	task codegenWrite: file.Create & {
		filename: "env.codegen.cue"
		contents: codegen.code
	}

	task codegenSetup: exec.Run & {
		cmd: ["bash", "-c", codegen.setup]
	}
}

// Generate import/apply CUE code from env config
codegen : {
	code: """
		import (
			\(strings.Join([import.code for _, import in codegen.imports if !import.setupOnly], "\n"))
		)

		\(strings.Join([apply.code for _, apply in codegen.apply if !apply.import.setupOnly], "\n"))
		"""

	setup: """
		\(strings.Join([import.setup for _, import in codegen.imports], "\n"))
		"""

	imports: {...}
	apply: {...}
	
	// Always import linux/container for internal use (build component containers)
	// FIXME
	// imports "linux/container" setupOnly: true
	// imports "linux/alpine/container" setupOnly: true

	for _, e in env|{} {
		for _, c in e.component {
			if c.blueprint != "" {
				imports "\(c.blueprint)": {}
				apply "\(c.name)": {
					import: imports[c.blueprint]
					code: """
						// Apply blueprint '\(c.blueprint)' to component '\(c.name)'
						env "\(e.name)" component "\(c.name)": /* Component & */ \(import.symbol)
						"""
				}
			}
		}
	}

	imports <importSource>: {
		source: importSource
		symbol: *strings.Replace(source, "/", "_", -1)|string
		cueSource: "infralabs.io/stdlib/\(source)"
		code: """
			// Import CUE package for blueprint '\(source)'
			\(symbol) "\(cueSource)"
			"""
		pkgCopyFrom: "catalog/component/\(source)"
		pkgCopyTo: "pkg/\(cueSource)"
		setupOnly: *false|bool
		setup: "mkdir -p '\(pkgCopyTo)' && rsync -aH --delete '\(pkgCopyFrom)/' '\(pkgCopyTo)/'"
	}
}

