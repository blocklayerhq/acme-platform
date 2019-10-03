workspace "acme.infralabs.io" prod: {
	components: {
		"acme-clothing": {
			blueprint: "acme.infralabs.io/clothing"
			components: {
				"api/container" settings prefix: "gcp.io/deploy-test-231020"
				"api/db" settings host: {
					public: "34.94.9.17"
					private: "10.32.225.3"
				}
			}
		}
	}
}
