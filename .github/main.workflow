workflow "Blocklayer" {
  on = "push"
  resolves = ["bl-run"]
}

# Filter to pushes to a specific branch. In this case, master.
action "master-branch-filter" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "bl-run" {
  uses = "./.github/actions/bl"
  needs = "master-branch-filter"
  env = {
    BL_PIPELINE = "acme-clothing-staging"
    BL_INPUT_OVERRIDE = "git.clone.web.ref"
    BL_API_SERVER = "http://api.infralabs.io:8080/query"
  }
}
