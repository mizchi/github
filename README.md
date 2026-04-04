# mizchi/github

GitHub REST API client for MoonBit (native target).

Built on `moonbitlang/async` (http, tls, socket).

## Install

```
moon add mizchi/github
```

## Usage

```moonbit
async fn main {
  let client = @client.GitHubClient::new(token)
  defer client.close()

  // Get authenticated user
  let me = @users.get_authenticated(client)

  // List workflow runs
  let runs = @actions.list_workflow_runs(client, "owner", "repo", branch="main")

  // Create an issue
  let issue = @issues.create(client, "owner", "repo", "Bug report", body="Details here")

  // Create a pull request
  let pr = @pulls.create(client, "owner", "repo", "Fix bug", "feature", "main")
}
```

## API

### client
`new`, `get_json`, `get_binary`, `post_json`, `patch_json`, `put_json`, `delete`, `close`

### actions
`list_workflow_runs`, `list_artifacts`, `download_artifact`

### repos
`get`, `get_content`, `list_branches`, `list_tags`, `list_releases`, `get_latest_release`

### issues
`list`, `get`, `create`, `update`, `add_labels`, `list_comments`, `create_comment`

### pulls
`list`, `get`, `create`, `update`, `list_files`, `list_reviews`, `request_reviewers`, `merge`

### git
`get_ref`, `create_ref`, `delete_ref`, `get_commit`, `get_tree`

### users
`get_authenticated`, `get`

## License

MIT
