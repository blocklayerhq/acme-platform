package kubernetes

test: simpleLoad: Load & {
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

test: simpleSave: Save & {
	input: {
		deployment: foo: {
			metadata: name: "foo"
			kind: "Deployment"
			spec: hello: "world"
		}
		service: foo: {
			kind: "Service"
			metadata: name: "foo"
		}
	}
}

test: simpleSaveYaml: SaveYaml & {
	input: test.simpleSave.input
}
