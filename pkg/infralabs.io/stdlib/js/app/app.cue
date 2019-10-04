package app

app: {
	settings: {
		build: {
			tool: *"npm"|"yarn"
			script: *"build"|string
			dir: *"build"|string
			envFile?: string
			env <Key>: string
		}
	}
	
	//	 FIXME: pull npm dependencies in pull() ?
	//	 	- If no: how to make builds reproducible?
	//		- If yes: how to differentiate "pull app dependencies" from "pull app code"?
	//				-> and how override app code while still pulling required dependencies?
	assemble: #"""
		# 1. Copy input source to cache, EXCLUDING node_modules
		rsync -aH --delete input/ --exclude=/node_modules/ cache/src/
		if [ -d cache/src/node_modules ]; then
			echo "using cached node_modules"
		fi
		# 2. Create node_modules in cache if it doesn't exist
		mkdir -p cache/src/node_modules
		# 3. Source the build env (optional)
		echo ===FIXME===
		## 4. Build in-place in cached source
		(
			# Install dependencies and run build script
			cd cache/src
			npm install
			npm run '\#(settings.build.script)'
		)
		# 5. Copy build directory to output
		mkdir -p output/
		rsync -aH cache/src/"$build_dir"/ output/
		"""#
	
	install: {
		engine: [0, 0, 3] // Install on alpha 3 engine
		packages: {
			npm: true
			rsync: true
		}
	}
}
