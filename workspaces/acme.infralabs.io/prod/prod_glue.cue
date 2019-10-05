import (
	"infralabs.io/bl"
	acmeClothing "acme.infralabs.io/acme/clothing"
	mysqlDatabase "infralabs.io/stdlib/mysql/database"
	gitRepo "infralabs.io/stdlib/git/repo"
	jsApp "infralabs.io/stdlib/js/app"
	netlifySite "infralabs.io/stdlib/netlify/site"
	kubernetesGke "infralabs.io/stdlib/kubernetes/gke"
	linuxAlpineContainer "infralabs.io/stdlib/linux/alpine/container"
)



// 1. COMMON GLUE

workspace <Domain> <Env>: bl.Workspace & {
	domain: *Domain|string
	env: Env
}


// 2. WORKSPACE-SPECIFIC GENERATED GLUE

workspace "acme.infralabs.io" prod: acmeClothing.clothing & {
	gates: {
		"monorepo": gitRepo.repo
		"api/app": jsApp.app
		"api/container": linuxAlpineContainer.container
		"api/db": mysqlDatabase.database
		"api/kube": kubernetesGke.gke
		"web/netlify": netlifySite.site
		"web/app": jsApp.app
	}
}
