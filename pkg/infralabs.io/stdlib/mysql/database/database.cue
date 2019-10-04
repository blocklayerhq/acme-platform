package database

database: {

	slug: _

	auth: {
		user: *"root"|string
		password: string
	}

	settings: {
		dbName: *slug|string
		host: {
			public: string
			private: string
		}
	}

	install: {
		engine: [0, 0, 3]
		packages: {
			terraform: {}
		}

		installCmd: #"""
			# + a hack to pre-install the mysql plugin for terraform
			# Note: super annoying that terraform doesn't let me do this
			run mkdir -p /var/terraform/plugins \
				&& echo 'provider "mysql" { endpoint = "ton cul" }' > /var/terraform/fake.tf \
				&& cd /var/terraform \
				&& terraform init --input=false
			cat <<-EOF > tmp/sql.tf
			provider "mysql" {
				endpoint="\#(settings.host.public)"
				username="\#(auth.user)"
				password="\#(auth.password)"
			}
			resource "mysql_database" "\#(settings.dbName)" {
				name = "\#(settings.dbName)"
			}
			EOF
			(
				cd tmp
				terraform init --input=false --get=false --get-plugins=false --plugin-dir=/var/terraform/.terraform/plugins/linux_amd64
				terraform import "mysql_database.$db_name" "$db_name" || true
				terraform apply --auto-approve --input=false
			)
			cp tmp/*.tf outputs/terraform_config
			"""#
	}

	push: """
		# FIXME: inject SQL data into the database,
		# for example for test fixtures
		"""
}
