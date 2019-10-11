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
		if [ ! -d cache/mirror ]; then
			git clone --progress --mirror '\(settings.url)' cache/mirror
		fi
		git -C cache/mirror  remote update
		if [ ! -d cache/cloned ]; then
			git clone --reference cache/mirror '\(settings.url)' cache/cloned
		else
			git -C cache/cloned fetch --all
		fi
		"""

	stage: """
		if [ "$(ls -A input/ | wc -l)" -eq 0 ]; then
			echo No input to process
			exit 0
		fi
		rsync -aH --delete cache/cloned/ output/
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
