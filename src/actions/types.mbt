///| A workflow run from GitHub Actions.
pub struct WorkflowRun {
  id : Double
  head_branch : String
  head_sha : String
  event : String
  conclusion : String
  created_at : String
  run_started_at : String
  updated_at : String
} derive(Show, Eq, FromJson, ToJson)

///| Response from listing workflow runs.
pub struct ListWorkflowRunsResponse {
  total_count : Int
  workflow_runs : Array[WorkflowRun]
} derive(Show, Eq, FromJson, ToJson)

///| An artifact from a workflow run.
pub struct Artifact {
  id : Double
  name : String
  expired : Bool
} derive(Show, Eq, FromJson, ToJson)

///| Response from listing artifacts.
pub struct ListArtifactsResponse {
  total_count : Int
  artifacts : Array[Artifact]
} derive(Show, Eq, FromJson, ToJson)
