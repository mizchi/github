///|
/// A workflow run from GitHub Actions.
pub struct WorkflowRun {
  id : Double
  head_branch : String
  head_sha : String
  event : String
  conclusion : String
  created_at : String
  run_started_at : String
  updated_at : String
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for WorkflowRun with fn output(self, logger) {
  logger.write_string("{id: ")
  logger.write_string(@debug.to_string(self.id))
  logger.write_string(", head_branch: ")
  logger.write_string(@debug.to_string(self.head_branch))
  logger.write_string(", head_sha: ")
  logger.write_string(@debug.to_string(self.head_sha))
  logger.write_string(", event: ")
  logger.write_string(@debug.to_string(self.event))
  logger.write_string(", conclusion: ")
  logger.write_string(@debug.to_string(self.conclusion))
  logger.write_string(", created_at: ")
  logger.write_string(@debug.to_string(self.created_at))
  logger.write_string(", run_started_at: ")
  logger.write_string(@debug.to_string(self.run_started_at))
  logger.write_string(", updated_at: ")
  logger.write_string(@debug.to_string(self.updated_at))
  logger.write_string("}")
}

///|
/// Response from listing workflow runs.
pub struct ListWorkflowRunsResponse {
  total_count : Int
  workflow_runs : Array[WorkflowRun]
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for ListWorkflowRunsResponse with fn output(self, logger) {
  logger.write_string("{total_count: ")
  logger.write_string(@debug.to_string(self.total_count))
  logger.write_string(", workflow_runs: ")
  logger.write_string(@debug.to_string(self.workflow_runs))
  logger.write_string("}")
}

///|
/// An artifact from a workflow run.
pub struct Artifact {
  id : Double
  name : String
  expired : Bool
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for Artifact with fn output(self, logger) {
  logger.write_string("{id: ")
  logger.write_string(@debug.to_string(self.id))
  logger.write_string(", name: ")
  logger.write_string(@debug.to_string(self.name))
  logger.write_string(", expired: ")
  logger.write_string(@debug.to_string(self.expired))
  logger.write_string("}")
}

///|
/// Response from listing artifacts.
pub struct ListArtifactsResponse {
  total_count : Int
  artifacts : Array[Artifact]
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for ListArtifactsResponse with fn output(self, logger) {
  logger.write_string("{total_count: ")
  logger.write_string(@debug.to_string(self.total_count))
  logger.write_string(", artifacts: ")
  logger.write_string(@debug.to_string(self.artifacts))
  logger.write_string("}")
}
