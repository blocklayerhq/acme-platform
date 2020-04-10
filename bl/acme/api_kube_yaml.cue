package acme

// FIXME: we are mocking an attachment API that does not exist
attachment: "api_kube.yaml": contents: """
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
    name: ingressroutetls
spec:
    entryPoints:
      - websecure
    routes:
    - kind: Rule
      services:
      - name: acme-clothing-api
        port: 8000
    tls:
        certResolver: acmeresolver
---
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
              - name: api
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
                command: ["npm", "run", "setup:db"]
                env:
                volumeMounts:
                  - name: api-db-config
                    subPath: json
                    mountPath: /src/src/config/database.json
                    readOnly: true
---
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
"""
