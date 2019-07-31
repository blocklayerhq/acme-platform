
import (
	"github.com/blocklayerhq/bl/fs"
	"github.com/blocklayerhq/bl/git"
)

type Pipeline struct {
	Config {}
	Input {}

	monorepo	*git.Repository
	frontendSource	*fs.Subtree
	frontendBuild	*yarn.Build
	backendSource	*fs.Subtree
	
}

func New() *Pipeline {
	var p Pipeline
	p.frontendSource = git.NewRepository("https://github.com/ahfarmer/calculator.git")
	p.frontendBuild = yarn.NewBuild(p.frontendSource.Tree)
	return &p
}
