package main

import (
	"strings"
)

View :: {
	name: string
	e = env[name]

	inputs: kvtable & {
		kind: "input"
		data: e.input | *{}
	}

	outputs: kvtable & {
		kind: "output"
		data: e.output | *{}
	}

	markdown:
		"""
		## Environment: \(name)

		### Inputs

		\(inputs.markdown)

		### Outputs

		\(outputs.markdown)
		"""

	html: """
		<div id="env.\(name)">
			<h2>Environment: \(name)</h2>

			<div id="\(name)-inputs">
				<h3>Inputs</h3>
				\(inputs.html)
			</div>

			<div id="env.\(name).outputs">
				<h3>Outputs</h3>
				\(outputs.html)
			</div>
		</div>
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
		dataRows: [ [k, v] for k, v in kv ]
	}

	markdown: t.markdown
	html:     t.html
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

	htmlHeaderRow:
			"""
		<th>
		\(strings.Join([ "	<td>\(cell)</td>" for cell in headerRow ], "\n"))
		</th>
		"""
	htmlDataRows: [
			"""
		<tr>
		\(strings.Join([ "	<td>\(cell)</td>" for cell in row ], "\n"))
		</tr>
		"""
			for row in dataRows
	]
	htmlRows: [htmlHeaderRow] + htmlDataRows
	html:     """
		<table>
		\(strings.Join(htmlRows, "\n"))
		</table>
		"""
}
