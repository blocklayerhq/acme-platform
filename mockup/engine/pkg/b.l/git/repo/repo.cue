package repo

settings: {
	url: string
	ref: *"master"|string
}

info: {
	commitID: string
	shortCommitID: string
}

action: {
	pull: """
		pwd
		if [ -z "$(ls -A input)" ]; then
			git clone --progress --mirror '\(settings.url)' input/
		fi
		git -C input/ remote update
		"""

	stage: """
		if [ ! -e input/.git ]; then
			echo No input to process
			exit 0
		fi
		rsync -acH input/ output/
		git -C output/ reset --hard '\(settings.ref)'
		git -C output/ rev-parse '\(settings.ref)' > info/commitID
		git -C output/ rev-parse --short '\(settings.ref)' > info/shortCommitID
		"""
}

container: {
	engine: [0, 0, 3]
	packages: {
		git: true
		"openssh-client": true
		rsync: true
	}
}
