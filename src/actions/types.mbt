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
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for WorkflowRun with fn output(self, logger) {
  logger.write_string("{id: ")
  self.id.output(logger)
  logger.write_string(", head_branch: ")
  self.head_branch.output(logger)
  logger.write_string(", head_sha: ")
  self.head_sha.output(logger)
  logger.write_string(", event: ")
  self.event.output(logger)
  logger.write_string(", conclusion: ")
  self.conclusion.output(logger)
  logger.write_string(", created_at: ")
  self.created_at.output(logger)
  logger.write_string(", run_started_at: ")
  self.run_started_at.output(logger)
  logger.write_string(", updated_at: ")
  self.updated_at.output(logger)
  logger.write_string("}")
}

///|
/// Response from listing workflow runs.
pub struct ListWorkflowRunsResponse {
  total_count : Int
  workflow_runs : Array[WorkflowRun]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for ListWorkflowRunsResponse with fn output(self, logger) {
  logger.write_string("{total_count: ")
  self.total_count.output(logger)
  logger.write_string(", workflow_runs: ")
  self.workflow_runs.output(logger)
  logger.write_string("}")
}

///|
/// An artifact from a workflow run.
pub struct Artifact {
  id : Double
  name : String
  expired : Bool
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Artifact with fn output(self, logger) {
  logger.write_string("{id: ")
  self.id.output(logger)
  logger.write_string(", name: ")
  self.name.output(logger)
  logger.write_string(", expired: ")
  self.expired.output(logger)
  logger.write_string("}")
}

///|
/// Response from listing artifacts.
pub struct ListArtifactsResponse {
  total_count : Int
  artifacts : Array[Artifact]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for ListArtifactsResponse with fn output(self, logger) {
  logger.write_string("{total_count: ")
  self.total_count.output(logger)
  logger.write_string(", artifacts: ")
  self.artifacts.output(logger)
  logger.write_string("}")
}
