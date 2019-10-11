package bl

import (
	"tool/exec"
)

currentEnv="acme"

command stage: {
	task stge: exec.Run & {
		cmd: ["cat"]
		stdin: engine.action.env[currentEnv].stage.script.out
	}
}
