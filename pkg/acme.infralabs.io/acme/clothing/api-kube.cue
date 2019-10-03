package clothing

import (
	"encoding/yaml"
)

// FIXME: importing raw yaml for speed, but ideally convert to native cue
address: _
components: _
container=components["api/container"]
db=components["api/db"]

components "api/kube" settings resources: [
	/* FIXME
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
				- \(address.api.host)
				secretName: api-tls
			rules:
			- host: \(address.api.slug)
				http:
				paths:
					- path: /
					backend:
						serviceName: acme-clothing-api
						servicePort: 8000
		"""),
	*/
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
					username: "\(db.auth.user)",
					password: "\(db.auth.password)",
					database: "\(db.settings.dbName)",
					host: "\(db.settings.host.public)",
					dialect: "mysql",
					seederStorage: "sequelize"
				}
			  '
		""")
]


