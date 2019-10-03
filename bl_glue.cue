import (
	"infralabs.io/bl"
)

workspace <Domain> <Name>: bl.Workspace & {
	domain: Domain
	name: Name
	components <C>: bl.Component
}

address <Name>: bl.Address
