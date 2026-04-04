///| List workflow runs for a repository.
pub async fn list_workflow_runs(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  branch? : String,
  created? : String,
  per_page? : Int,
) -> ListWorkflowRunsResponse raise {
  let pp = per_page.unwrap_or(30)
  let mut path = "/repos/\{owner}/\{repo}/actions/runs?per_page=\{pp}"
  match branch {
    Some(b) => path = path + "&branch=\{b}"
    None => ()
  }
  match created {
    Some(c) => path = path + "&created=\{c}"
    None => ()
  }
  let json = client.get_json(path)
  @json.from_json(json)
}

///| List artifacts for a specific workflow run.
pub async fn list_artifacts(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  run_id : Double,
) -> ListArtifactsResponse raise {
  let id = run_id.to_int64()
  let path = "/repos/\{owner}/\{repo}/actions/runs/\{id}/artifacts"
  let json = client.get_json(path)
  @json.from_json(json)
}

///| Download an artifact as a ZIP archive (raw bytes).
pub async fn download_artifact(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  artifact_id : Double,
) -> Bytes {
  let id = artifact_id.to_int64()
  client.get_binary("/repos/\{owner}/\{repo}/actions/artifacts/\{id}/zip")
}
