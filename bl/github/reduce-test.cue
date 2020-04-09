package github

test: SimpleReduce: {

	events: {...} | *{}

	r: EventReduce & {
		e: events
	}
}
