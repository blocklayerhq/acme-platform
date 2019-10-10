package bl

env "acme" component "monorepo": {

// Change this to the component blueprint to use
// To search for available component blueprints: "./blx component search"
    blueprint: "git/repo"

    settings: {
        // Env-specific component settings here
		url: "https://github.com/atulmy/crate"
    }
}

