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

  // List workflow runs
  let runs = @actions.list_workflow_runs(
    client, "owner", "repo",
    branch="main",
    per_page=10,
  )

  // List artifacts for a run
  let artifacts = @actions.list_artifacts(
    client, "owner", "repo", runs.workflow_runs[0].id,
  )

  // Download artifact as ZIP bytes
  let zip = @actions.download_artifact(
    client, "owner", "repo", artifacts.artifacts[0].id,
  )
}
```

## Packages

- `mizchi/github/client` — HTTP client with GitHub auth, JSON/binary helpers
- `mizchi/github/actions` — GitHub Actions API (workflow runs, artifacts)

## License

MIT
