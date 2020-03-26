package kubernetes

test: simpleLoad : Load & {
	input: [{
		kind: "deployment"
		metadata: name: "foo"
	}]
}

test: simpleLoadYaml: LoadYaml & {
	input: """
		---
		kind: deployment
		metadata:
		    name:
		        "foo"
		hello: "world"
		---
		kind: service
		metadata:
		    name:
		        "foo"
		hello: "world!!!"
		"""
}
