package graphql

import (
	"strings"
	"encoding/json"
	"acme.infralabs.io/http"
)

Query :: {
	// Contents of the graphql query (minus the surrounding `query { }`
	query: string

	// We remove all newlines from the query, as some server implementations (eg Github) don't accept them.
	// We also remove tabs, just in case.
	queryOneLiner = strings.Replace(strings.Replace(query, "\n", " ", -1), "\t", " ", -1)

	result: _ | *null

	// Raw HTTP response
	response: _
	if json.Valid(response) {
		result: json.Unmarshal(response)
	}

	http.Request & {
		body:   json.Marshal({"query": "query { \(queryOneLiner) }"})
		method: "POST"
	}
}
