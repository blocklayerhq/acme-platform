package container

container: {
	input: _

	settings: {
		tool: *"npm"|string
		build: {
			env <Key>: _
			script: string
			dir: string
		}
		run: {
			env <Key>: _
			script: string
		}
	}

	components: {
		js: {
			blueprint: "js/app"
			input from: container.input.from
			settings build: {
				tool: container.settings.tool
			}
		}

		linux: {
			blueprint: "linux/alpine/container"
			input from: js.output
			settings: {
				alpineVersion: [3, 10]
				packages: {
					npm: true
					gcc: true
					"g++": true
					make: true
					python: true
				}
				postinstall: [
					["npm", "install", "-g", "nodemon", "babel-cli"]
				]
				appRun: [container.settings.tool, "run", container.settings.run.script]
			}
		}
	}
}
