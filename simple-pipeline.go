
import (
	"blocklayerhq.com/bl/fs"
	"blocklayerhq.com/bl/git"
)

type Pipeline struct {
	Config {}
	Input {}

	frontendSource *git.Repository
	frontendBuild  *yarn.Build
}

func New() *Pipeline {
	var p Pipeline
	p.frontendSource = git.NewRepository("https://github.com/ahfarmer/calculator.git")
	p.frontendBuild = yarn.NewBuild(p.frontendSource.Tree)
	return &p
}
