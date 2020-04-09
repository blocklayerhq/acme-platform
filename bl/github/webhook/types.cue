package webhook

// Raw data structures from Github API
// https://developer.github.com/v3/activity/events/types/#pullrequestevent

Timestamp :: string & =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"
SHA ::       string & =~"^[0-9a-fA-F]{40}$"
URL:         string & =~"^[a-z]+://.*$"
SSHURL:      string

Event :: {
	...
}

PullRequestEvent :: {
	action:
		"assigned" |
		"unassigned" |
		"assigned" |
		"review_requested" |
		"review_request_removed" |
		"labeled" |
		"unlabeled" |
		"opened" |
		"edited" |
		"closed" |
		"ready_for_review" |
		"locked" |
		"unlocked" |
		"reopened"

	number: int
	changes: {...}
	pull_request: PullRequest
	repository:   Repository
	sender:       User

	// FIXME: once all missing fields are defined, close this definition
	...
}

// A pull request as represented by the Github API
PullRequest :: {
	Object

	html_url:         string
	diff_url:         string
	patch_url:        string
	issue_url:        string
	number:           int
	state:            PullRequestState
	locked:           bool
	title:            string
	user:             User
	body:             string
	created_at:       Timestamp
	updated_at:       Timestamp
	closed_at:        Timestamp | null
	merged_at:        Timestamp | null
	merge_commit_sha: SHA | null
	assignee:         string | null

	head: {
		label: string
		ref:   string
		sha:   SHA
		user:  User
		repo:  Repository
	}
	base: {
		label: string
		ref:   string
		sha:   SHA
		user:  User
		repo:  Repository
	}
	"_links": {
		self: href:            URL
		html: href:            URL
		issue: href:           URL
		comments: href:        URL
		review_comments: href: URL
		review_comment: href:  URL
		commits: href:         URL
		statuses: href:        URL
	}
	author_association:    string | "OWNER"
	draft:                 bool
	merged:                bool
	mergeable:             _ | null
	rebaseable:            _ | null
	mergeable_state:       "unknown" | string
	merged_by:             null | _
	comments:              int
	review_comments:       int
	maintainer_can_modify: bool
	commits:               int
	additions:             int
	deletions:             int
	changed_files:         int

	// FIXME: once all missing fields are defined, close this definition
	...
}

// A repository as represented by the Github API
Repository :: {
	Object
	name:              string
	full_name:         string
	private:           bool
	owner:             User
	html_url:          string
	description:       string | null
	fork:              bool
	forks_url:         URL
	keys_url:          URL
	collaborators_url: URL
	teams_url:         URL
	hooks_url:         URL
	issues_events_url: URL
	events_url:        URL
	assignees_url:     URL
	branches_url:      URL
	tags_url:          URL
	// FIXME: skipping fields here
	created_at:     Timestamp
	updated_at:     Timestamp
	pushed_at:      Timestamp
	git_url:        URL & =~"^git://"
	ssh_url:        SSHURL
	clone_url:      URL
	svn_url:        URL
	default_branch: string

	// FIXME: once all missing fields are defined, close this definition
	...
}

PullRequestState :: "open" | "closed"

User :: {
	Object
	login:               string
	avatar_url:          string
	gravatar_id:         string
	html_url:            string
	followers_url:       string
	following_url:       string
	gists_url:           string
	starred_url:         string
	subscriptions_url:   string
	organizations_url:   string
	repos_url:           string
	events_url:          string
	received_events_url: string
	type:                "User"
	site_admin:          bool

	// FIXME: once all missing fields are defined, close this definition
	...
}

// An object in the Github API
Object :: {
	id:      int
	node_id: string
	url:     URL
}
