import (
	"strings"

	"bl"
	"bl/git"
	"bl/cloudflare"
	"bl/dns"
	"bl/fs"
	"bl/docker"
	"bl/googlecloud"
	"bl/netlify"
)

type Pipeline struct {
	Domain			dns.Domain
	Monorepo		git.Repository
	AppSubdomain		dns.Domain
	Domain			dns.Domain
	CloudflareZone		cloufdlare.Zone
	FrontendDns		cloudflare.Record
	ApiDns			cloudflare.Record
	ApiSource		fs.Directory
	ApiDockerImage		docker.Image
	ApiDockerRepo		googlecloud.Repository
	ApiKubernetesConfig	fs.File
	ApiKubernetesDeployment	googlecloud.KubernetesDeployment
	ApiDb			googlecloud.MysqlDatabase
	FrontendSource		fs.Directory
	FrontendNpmBuild	fs.Directory
	FrontendNetlifySite	netlify.Site
}

func New() *Pipeline {
	var p Pipeline

	p.Domain.Name = bl.Prompt()
	p.Monorepo.Url = "https://github.com/atulmy/crate.git"
	p.AppSubdomain.Name = bl.From(bl.PipelineName(), p.Domain.

	return &Pipeline{
		Domain: dns.Domain{
			Name: bl.Prompt(),
		},
	}
}

func Deploy() {

	bl.Add("domain", dns.Domain{
		Name = bl.Prompt(),
	})

	bl.Add("monorepo", git.Repository{
		Url: "https://github.com/atulmy/crate.git",
	})

	bl.Add("subdomain", dns.Domain{
		Name: bl.
			From(bl.PipelineName, bl."bl.PipelineName", "domain.name").
			Do(func(c bl.Connector) {
				name := e.System.PipelineName
				name_url_safe := strings.ReplaceAll(name, "_", "-")
				domainName := e.Domain.Name
			var domainName = c.Get("domain.
			c.Set(
				"subdomain.Name",
				fmt.Sprintf(
					"%s.%s",
name_url_safe, c.Get("domain.Name")))
			
		})
	})
	bl.Connect().
		Inputs("bl.PipelineName", "domain.Name").
		Outputs("subdomain.Name").
		Action(func(c bl.Connector) {
		})
	})

	bl.Add("dns_zone", cloudflare.Zone{
		Name: bl.Prompt(),
		Token: bl.Prompt(),
		Email: bl.Prompt(),
	})

	bl.Add("frontend_dns_record", cloudflare.Record{
		Type: "CNAME",
	})
	bl.Connect().
		Inputs("subdomain.Name")
		Outputs("frontend_dns_record.Name")

	bl.Add("api_dns_record", &cloudflare.Record{
		type: "A",
	})

}
