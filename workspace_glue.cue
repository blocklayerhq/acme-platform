import (
	"infralabs.io/bl"

	"acme.infralabs.io/acme/clothing"
)

workspace <Domain> <Name>: bl.Workspace & {
	domain: Domain
	name: Name
	components <C>: bl.Component
}

address <Name>: bl.Address



/* APP-SPECIFIC GENERATED GLUE BELOW */

workspace "acme.infralabs.io" prod components: {
	"acme-clothing": clothing & {
		...
	}
}
