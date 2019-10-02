
package acmeclothing

// NOTES:
//
// - each component has a a 'address' field which is its globally unique identifier
//		a component address cannot be changed. It should be used for annotation & name mangling
//		of external resources.
//
// - As a convenience, the component address has a 'slug' field: an approximation of the address using
//		a reduced character set, so that it can be used as a key in as many external systems
//		as possible (eg. kubernetes namespace, sql database name, etc)
//
//
// - microstaging flow: components/environments can be "staged". A staging component is linked
//		to its parent. The parent can access its staging environments (potentially many of them).
//		staging can be nested.
//		staging tree can model organization tree.

import (
	"blocklayerhq.com/bl"
	"blocklayerhq.com/components/git"
	"blocklayerhq.com/components/js"
	"blocklayerhq.com/components/linux"
	"blocklayerhq.com/components/kubernetes"
	"blocklayerhq.com/components/netlify"
	"blocklayerhq.com/components/sql"
)

// Use an alias for the netlify package to avoid name conflicts
ntlfy=netlify.Site

AcmeClothing : bl.Component & {
	subcomponents: {
		monorepo: git.Repo & {
			settings: {
				url: "https://github.com/atulmy/crate.gi"
			}
		}

		web: {
			_address=address
			description: "Acme Clothing web frontend"
			subcomponents: {
				app: js.App & {
					input: {
						from: monorepo
						fromDir: "code/web"
					}
					settings: {
						build: {
							tool: "npm"
							script: "build:client"
							dir: "public"
							envFile: ".env"
							env: {
								NODE_ENV: "production"
								APP_URL: "https://\(_address)"
								APP_URL_API: "https://\(api.address)"
							}
						}
					}
				}
				netlify: ntlfy.Site & {
					input from: app
					settings: {
						siteName: string|*_address
						customDomain: _address
					}
				}
			}
		}

		api: {
			address: *"api.\(_address)"|string
			description: "Acme Clothing API backend"
			subcomponents: {
				container: linux.alpine.AppContainer & {
					input: {
						from: monorepo
						fromDir: "code/api"
						checksum: _
					}
					settings: {
						registry: string
						pushTo: {
							name: "\(settings.registry)/\(api.slug)"
							tag: input.checksum
						}
						alpineVersion: [3, 10]
						packages: {
							npm install: {
									nodemon: {}
									"babel-cli": {}
							}
							gcc: {}
							"g++": {}
							make: {}
							python: {}
						}
						env: {
							NODE_ENV: "production"
						}
						appDir: "/src"
						appInstall: """
							run npm install
							run npm run build:prod
							"""
						cmd: ["npm", "run", "start:server"]
					}
				}
				db: sql.Database & {
					settings dbName: *api.slug|string
				}
				kube: kubernetes.GKE.Deployment & {
					settings: {
						namespace: *api.slug|string
						// FIXME: importing raw yaml for speed, but ideally convert to native cue
						resources: [
							yaml.Unmarshal("""
								apiVersion: extensions/v1beta1
								kind: Ingress
								metadata:
								  name: api-public-endpoint
								  annotations: 
									kubernetes.io/ingress.class: traefik
									certmanager.k8s.io/cluster-issuer: letsencrypt-prod
									certmanager.k8s.io/acme-http01-edit-in-place: "true"
								spec:
								  tls:
									- hosts:
										- $API_HOSTNAME
									  secretName: api-tls
								  rules:
									- host: \(slug)
									  http:
										paths:
										  - path: /
											backend:
											  serviceName: acme-clothing-api
											  servicePort: 8000
								"""),
							yaml.Unmarshal("""
								apiVersion: extensions/v1beta1
								kind: Deployment
								metadata:
								  name: acme-clothing-api
								spec:
								  replicas: 1
								  template:
									metadata:
									  labels:
										app: acme-clothing-api
									spec:
									  volumes:
									   - name: api-db-config
										 secret:
										   secretName: api-db-config
										   items:
										   - key: json
											 path: json
									  containers:
										- image: \(container.info.pushedTo)
										  name: api
										  command: ["npm", "run", "start:server"]
										  volumeMounts:
											- name: api-db-config
											  subPath: json
											  mountPath: /src/build/config/database.json
											  readOnly: true
										  ports:
											- name: api-port
											  containerPort: 8000
											- name: debug-port
											  containerPort: 8001
										  env:
									  initContainers:
										- name: db-setup
										  image: \(container.info.pushedTo)
										  command: ["npm", "run", "setup:db"]
										  env:
										  volumeMounts:
											- name: api-db-config
											  subPath: json
											  mountPath: /src/src/config/database.json
											  readOnly: true
								"""),
								yaml.Unmarshal("""
									apiVersion: v1
									kind: Service
									metadata:
									  name: acme-clothing-api
									spec:
									  selector:
										app: acme-clothing-api
									  ports:
										- name: api-port
										  port: 8000
										  targetPort: 8000
										- name: debug-port
										  port: 8001
										  targetPort: 8001
									---
									apiVersion: v1
									kind: Secret
									metadata:
									  name: api-db-config
									type: Opaque
									stringData:
									  json: '
										{
											username: "\(db.settings.admin.user)",
											password: "\(db.settings.admin.password)",
											database: "\(db.settings.dbName)",
											host: "\(db.settings.host.public)",
											dialect: "mysql",
											seederStorage: "sequelize"
										}
									  '
								""")
							]
						}
				}
			}
		}
	}
}
