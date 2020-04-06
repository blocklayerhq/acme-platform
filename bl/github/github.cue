package github

import (
	"b.l/bl"
)

Repository :: {
	token: bl.Secret
	name:  string
	owner: string

	pr: [prId=string]: {
		id:     prId
		status: "open" | "closed"
		comments: [commentId=string]: {
			author: string
			text:   string
		}
		branch: {
			tip: {
				checkout: bl.Directory
			}
		}
	}
}
