package bl

import (
	"tool/exec"
)

currentEnv="acme"

for actionName, _ in Component.action {
		command "\(actionName)": {
			task run: exec.Run & {
				cmd: ["cat"]
				stdin: engine.action.env[currentEnv][actionName].script.out
			}
		}
}
