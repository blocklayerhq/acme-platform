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

// FIXME: define dev, staging and prod in the same pipeline
//     (this means prefixing all the stuff below with "dev"

type Pipeline struct {

	Config struct {
		DNS struct {
			TopLevelDomain	bl.String `desc:"Top-level domain for DNS config"`
			CloudflareToken	bl.String `desc:"Cloudflare API token" secret:true`
			CloudflareEmail	bl.String `desc:"Cloudflare account email"`
			CloudflareZone	bl.String `desc:"Cloudflare top-level zone name"`
		}
	}

	Inputs struct {
		EnvName	bl.String `desc:"Name of the environment to deploy to"`
	}

	// Fetch & split up source code repositories
	monorepo	git.Repository
	apiSource	fs.Directory		`deps:monorepo`
	webSource	fs.Directory		`deps:monorepo`

	// Configure DNS
	webDNS		dns.Record		`deps:Name,Config.DNS`
	apiDNS		dns.Record		`deps:Name,Config.DNS`

	// Build and deploy the API
	apiDockerImage	docker.Image		`deps:apiSourceCode`
	apiDockerRepo	gcloud.Repository	`deps:apiDockerImage,Name`
	apiKubConfig	fs.File			`deps:apiDockerRepo`
	apiKubNamespace	gcloud.KubNamespace	`deps:apiKubConfig,Name`

	// Provision the database
	apiDb		googlecloud.MysqlDB	`deps:Name side_effects:true`

	// Build and deploy the web frontend
	webNpmBuild	fs.Directory		`deps:webSource,webDNS,apiDNS`
	webNetlifySite	netlify.Site		`deps:webNpmBuild,Name`
}

func urlsafe(s string) string {
	return strings.ReplaceAll(s, "_", "-")
}

func New() *Pipeline {
	var p Pipeline

	// Fetch & Split up source code repositories
	p.monorepo = git.NewRepo("https://github.com/atulmy/crate.git")
	p.apiSource = fs.Subtree(p.monorepo, "code/api")
	p.webSource = fs.Subtree(p.monorepo, "code/web")

	// Configure DNS
	p.webDNS = cloudflare.NewRecord()
	p.webDNS.RecordType = bl.String("CNAME")
	p.webDNS.RecordName = bl.Stringf(func(tldomain, envname string) string {
			return fmt.Sprintf("%s.%s", urlsafe(envname), tldomain)
		},
		p.Config.DNS.TopLevelDomain, b.Input.EnvName
	)
	p.webDNS.RecordValue = bl.Stringf(func(envname string) string {
			return fmt.Sprtinf("%s.netlify.com", urlsafe(envname))
	}, p.Input.EnvName)

	// Build and deploy the API
	p.apiDockerImage = docker.Image(p.apiSource.Tree)
	p.apiDockerImage.Dockerfile = `
		from alpine as api
		run apk update
		run apk add npm
		run npm config set unsafe-perm true
		run apk add gcc g++ make
		run apk add python
		run ["npm", "install", "-g", "nodemon"]
		run ["npm", "install", "-g", "babel-cli"]
		copy . /src/
		workdir /src
		run npm install
		run npm run build:prod
		env NODE_ENV=production
		cmd ["npm", "run", "start:server"]
	`

	p.webDNS.CloudflareToken = p.Config.DNS.CloudflareToken
	p.webDNS.CloudflareEmail = p.Config.DNS.CloudflareEmail
	p.webDNS.CloudflareToken = p.Config.DNS.CloudflareToken
	p.webDNS.CloudflareZone  = p.Config.DNS.CloudflareZone
o



	p.apiDNS.RecordType = "A"
	p.apiDNS.Update = func(self *dns.Record, sandbox bl.Sandbox) {
		var (
			tldomain	= sandbox.Deps.GetString("Config.DNS.TopLevelDomain")
			envname		= sandbox.Deps.GetString("Name")
			webDNS		dns.Record
		)
		dns.LoadRecord(&webDNS, sandbox)
		apiDNS.Name = fmt.Sprintf("api.%s.%s", urlsafe(pipeline_name), tldomain)
	}

	// Build and deploy the API
	p.apiDockerImage.Update = func(sandbox bl.Sandbox) {
		// FIXME: actually Build the image
	}

	// csion the database
	p.apiDb.

	// Build and deploy the web frontend


	return &Pipeline{
		Domain: dns.Domain{
			Name: bl.Prompt(),
		},
	}
}




/*
func Deploy() {

	bl.Add("domain", dns.Domain{
		Name = bl.Prompt(),
	})

	bl.Add("monorepo", git.Repository{
		Url: "https://github.com/atulmy/crate.git",
	})

	bl.Add("subdomain", dns.Domain{
		Name: bl.Connect(func(c bl.Connector) {


		}, bl.


	})



		Name: bl.From().Do(func(c bl.Connector) {
			name_url_safe := strings.ReplaceAll(c.System.PipelineName, "_", "-")
			c.name_url_safe + "." + c.Domain.Name
		}),
			Do(func(c bl.Connector) {
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
*/
