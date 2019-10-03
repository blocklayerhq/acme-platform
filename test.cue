import (
	"infralabs.io/stdlib/linux/alpine/container"
)

mycontainer: container & {
	registry: "shykes/devbox"
}
