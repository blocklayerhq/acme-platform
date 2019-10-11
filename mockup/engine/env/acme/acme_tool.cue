package bl

import (
	"tool/exec"
	"tool/cli"
)

currentEnv="acme"

for actionName, _ in Component.action {

		command "\(actionName)": {
			task run: exec.Run & {
				cmd: ["bash", "-x"]
				stdin: engine.action.env[currentEnv][actionName].script.out
			}
		}

		command "\(actionName)-script": {
			task print: cli.Print & {
				text: engine.action.env[currentEnv][actionName].script.out
			}
		}
}

command openstate: {

	statedir = "/state/env/\(currentEnv)"
	imageName=engine.action.env[currentEnv].stage.imageName

	task build: exec.Run & {
		cmd: [
			"docker-buildx", "build",
			"-t", "\(imageName)-openstate",
			"--load",
			"-"
		]
		stdin: """
			FROM alpine
			RUN mkdir -p \(statedir)
			COPY --from=\(imageName) / \(statedir)
			"""
	}


	task run: exec.Run & {
		buildDone: task.build.success // Wait for build
		cmd: [
			"bash",
			"-x",
			"-c", """
				</dev/tty >/dev/tty docker run --rm -i -t -w \(statedir) \(imageName)-openstate
				"""
		]
	}
}
