package repo

settings: {
	url: string
	ref: *"master"|string
}

info: {
	commitID: string
	shortCommitID: string
}

pull: #"""
	if [ ! -d cache/mirror]; then
		git clone --progress --mirror '\#(settings.url)' cache/mirror
	fi
	git -C cache/mirror remote update
	git clone --reference cache/mirror '\#(settings.url)' input/
	"""#

assemble: #"""
	cp -a input/ output/
	git -C output/ reset --hard '\#(settings.ref)'
	git -C output/ rev-parse '\#(settings.ref)' > info/commitID
	git -C outputs/out rev-parse --short $(cat inputs/ref) > info/shortCommitID
	"""#

install: {
	engine: [0, 0, 3]
	packages: {
		git: {}
		"openssh-client": {}
	}
}
