package webhook

// EventReduce applies a reduce transformation to a stream of input events.
// FIXME: this doesn't have to be github-specific.
// FIXME: this would work better with an underlying `bl.Stream` type - but it still works without it.

EventReduce :: {

	// Input event
	e: webhook.Event

	// Reduced output
	reduce: json.Unmarshal(task.output[reducePath])

	// Reduce code (literal cue code in a string)
	cueCode: string | *#"""
		import (
			"strconv"
		)

		e: _
		reduce: {
			if (e.number & int) != _|_ {
				"\(strconv.FormatUint(e.number, 10))": {
					if (e.pull_request.state & string) != _|_ {
						state: e.pull_request.state
					}
				}
			}
		}
		"""#

	eventPath:  string | *"/event.json"
	sourcePath: string | *"/source.cue"
	reducePath: string | *"/reduce.json"

	task: bl.BashScript & {

		os: {
			package: {
				go:  true
				git: true
			}

			extraCommand: [
				#"""
				cd /tmp \
				&& git clone https://github.com/cuelang/cue \
				&& cd cue/cmd/cue \
				&& go build -o /usr/local/bin/cue
				"""#,
			]
		}

		// Disable op caching. Otherwise if the same event arrives twice, the task will be cached.
		runPolicy: "always"

		input: {
			"\(eventPath)":  json.Marshal(e)
			"\(sourcePath)": cueCode
			// FIXME: we want guaranteed persistence. Cache is the best we get (for now).
			"\(workdir)": bl.Cache
		}

		output: {
			"\(reducePath)": string
		}

		environment: {
			EVENT_PATH:  eventPath
			SOURCE_PATH: sourcePath
			REDUCE_PATH: reducePath
		}

		workdir: "/workdir"

		code: #"""
			#!/bin/bash

			echo foo
			set \
				-o errexit \
				-o xtrace

			# 1. Constant definitions
			# (fixme; move into an input
			{
				cat <<-EOF
					Transform :: {
					  e: _
					  reduce: {
					    ...
					  }
					}

					Transform

					EOF
			} > base.cue

			# 2. Import user reduce source code
			cp "$SOURCE_PATH" ./source.cue
			cue fmt -s ./source.cue

			# 3. Import new event to process
			if [ -e e.cue ]; then
				# Remove previous event if it exists
				rm e.cue
			fi
			cue import "$EVENT_PATH" -o ./e.cue -l '"e"'

			# 4. Import current state (result of past reduce)
			# - state.cue is generated from state.json
			# - state.json is produced by past runs (will not exist if this is first run)
			if [ -e state.cue ]; then
				rm state.cue
			fi
			if [ -e state.json ]; then
				cue import state.json -l '"reduce"' -o state.cue
			else
				touch state.cue
			fi

			# 5. Export new reduce
			cue export *.cue -e 'reduce' -o state.json

			echo "---- BEGIN REDUCE STATE ----"
			cat state.json
			echo "---- END REDUCE STATE ----"
			cp state.json "$REDUCE_PATH"
			"""#
	}
}
