package main

import (
	"b.l/bl"
	"strings"
)

directory: bl.Directory

secret :: bl.Secret & {value: string | *""}
task ::   bl.BashScript

queue :: {
	receive: _
}

table :: {
	headerRow: [...string]
	dataRows: [
		...[...string],
	]
	markdown: """
		|\(strings.Join(headerRow, "|"))|
		|\(strings.Join([ "-----" for _ in headerRow ], "|"))|
		\(strings.Join([ "|\(strings.Join(row, "|"))|" for row in dataRows ], "\n"))
		"""
}

kvtable :: {
	kind: string
	data: [string]: _

	kv: {
		for k, v in data {
			if (v & string) != _|_ {
				"\(k)": v
			}
			if (v & secret) != _|_ {
				"\(k)": v.value
			}
			if (v & directory) != _|_ {
				"\(k)": "[directory]"
			}
		}
	}

	t: table & {
		headerRow: ["\(strings.ToUpper(kind)) KEY", "\(strings.ToUpper(kind)) VALUE"]
		dataRows: [ [k, v | *""] for k, v in kv ]
	}

	markdown: t.markdown
}

inputTable ::  kvtable & {kind: "input"}
outputTable :: kvtable & {kind: "output"}

env: _

envView :: {
	envName: string

	e: env[envName]

	input:  inputTable & {data:  e.input}
	output: outputTable & {data: e.output}

	text: """
		Env: \(envName)

		\(input.markdown)

		\(output.markdown)
		"""
}
