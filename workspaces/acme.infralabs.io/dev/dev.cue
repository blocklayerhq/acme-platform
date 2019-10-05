
import (
	"infralabs.io/bl"
	"infralabs.io/stdlib/git/repo"
)

workspace <Domain> <Env>: bl.Workspace & {
	domain: *Domain|string
	env: Env
	gates <Name>: {
		name: Name
		address: *Domain|string
	}
}

workspace "acme.infralabs.io" dev: {
	gates: {
		monorepo: repo.repo& {
			blueprint: "git/repo"
			settings url: "https://github.com/shykes/devbox"
		}
	}
}
