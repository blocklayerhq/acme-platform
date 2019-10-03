workspace "acme.infralabs.io" prod: {
	components: {
		"acme-clothing": {
			address web host: "acme.infralabs.io"
			blueprint: "acme.infralabs.io/clothing"
			// FIXME: subcomponents settings should be grouped under the parent settings,
			// so that the user/installer does not need to overlay the .components field,
			// (it's confusing because we're installing some components and configuring
			// others with similar syntax)
			components: {
				"api/container" settings registry: "gcp.io/deploy-test-231020"
				"api/db" settings host: {
					public: "34.94.9.17"
					private: "10.32.225.3"
				}
			}
		}
	}
}
