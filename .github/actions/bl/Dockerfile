FROM blocklayer/bl:latest

LABEL "com.github.actions.name"="bl run"
LABEL "com.github.actions.description"="Create a Blocklayer Job"
LABEL "com.github.actions.icon"="play-circle"
LABEL "com.github.actions.color"="purple"

LABEL "repository"="http://github.com/blocklayerhq/blocklayer"
LABEL "homepage"="http://github.com/blocklayerhq/blocklayer"
LABEL "maintainer"="Blocklayer Team <hello@blocklayerhq.com>"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
