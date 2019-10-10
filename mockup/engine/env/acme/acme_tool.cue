package bl

import (
	"tool/exec"
)

currentEnv="acme"

command assemble: {

	for componentName, a in engine.action.assemble[currentEnv] {
			task "\(componentName)": exec.Run & {
				cmd: ["bash", "-x", "-c", a.buildscript]
			}
	}
}
