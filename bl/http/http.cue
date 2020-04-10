package http

import (
	"b.l/bl"
)

Request :: {
	url:    string
	body:   string | *""
	token?: bl.Secret
	method: *"GET" | "POST" | "PUT" | "DELETE" | "PATH" | "HEAD"

	context?: string
	if (context & string) != _|_ {
		send: runPolicy: "onChange"
		send: input: "/context": context
	}
	if (context & string) == _|_ {
		send: runPolicy: "always"
	}
	response: send.output["/response"]

	send: bl.BashScript & {
		os: package: curl: true
		input: {
			"/method": method
			if (token & bl.Secret) != _|_ {
				"/token": token
			}
			"/body": body
			"/url":  url
		}
		output: {
			"/response": string
		}
		code:
			#"""
			set -o xtrace -o errexit
			echo NO RESPONSE > /response
			curlArgs=(
				"$(cat /url)"
				-s -L
				-X "$(cat /method)"
				-d "$(cat /body)"
				-o /response
			)

			if [ -e /token ]; then
				curlArgs+=("-H" "Authorization: bearer $(cat /token)")
			fi

			curl "${curlArgs[@]}"
			"""#
	}
}
