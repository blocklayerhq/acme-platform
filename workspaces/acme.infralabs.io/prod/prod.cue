
workspace "acme.infralabs.io" prod: {
	template: "acme.infralabs.io/acme/clothing"
	gates: {
		"api/container" settings prefix: "gcp.io/deploy-test-231020"
		"api/db" settings host: {
			public: "34.94.9.17"
			private: "10.32.225.3"
		}
	}
}
