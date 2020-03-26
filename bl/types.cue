package main

import (
	"b.l/bl"
)

directory :: bl.Directory

secret :: bl.Secret & {value: string | *""}
task ::   bl.BashScript

queue :: {
	receive: _
}
