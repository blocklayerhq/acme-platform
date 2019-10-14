package bl

env acme: {

    // Target address goes here (eg. www.myapp.com)
    target: "localhost"

    keychain: {
        // Env-specific passwords & keys go here
    }

    settings: {
        // Env-specific settings go here
    }

	component monorepo: {

		// Change this to the component blueprint to use
		// To search for available component blueprints: "./blx component search"
    	blueprint: "git/repo"

    	settings: {
    	    // Env-specific component settings here
			url: "https://github.com/atulmy/crate"
    	}
	}
}
