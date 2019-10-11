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
	pull: #"""
		pwd
		if [ ! -d cache/mirror ]; then
			git clone --progress --mirror '\#(settings.url)' cache/mirror
		fi
		git -C cache/mirror remote update
		git clone --reference cache/mirror '\#(settings.url)' input/
		"""#

	assemble: #"""
		# cp -a input/ output/
		rsync -acH input/ output/
		git -C output/ reset --hard '\#(settings.ref)'
		git -C output/ rev-parse '\#(settings.ref)' > info/commitID
		git -C output/ rev-parse --short '\#(settings.ref)' > info/shortCommitID
		"""#
}

container: {
	engine: [0, 0, 3]
	packages: {
		git: true
		"openssh-client": true
		rsync: true
	}
}
