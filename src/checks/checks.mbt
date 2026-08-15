///|
/// A check run.
pub struct CheckRun {
  id : Double
  name : String
  status : String
  conclusion : String?
  html_url : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for CheckRun with fn output(self, logger) {
  logger.write_string("{id: ")
  self.id.output(logger)
  logger.write_string(", name: ")
  self.name.output(logger)
  logger.write_string(", status: ")
  self.status.output(logger)
  logger.write_string(", conclusion: ")
  self.conclusion.output(logger)
  logger.write_string(", html_url: ")
  self.html_url.output(logger)
  logger.write_string("}")
}

///|
/// Response from listing check runs.
pub struct ListCheckRunsResponse {
  total_count : Int
  check_runs : Array[CheckRun]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for ListCheckRunsResponse with fn output(self, logger) {
  logger.write_string("{total_count: ")
  self.total_count.output(logger)
  logger.write_string(", check_runs: ")
  self.check_runs.output(logger)
  logger.write_string("}")
}

///|
/// List check runs for a git reference (branch, tag, or SHA).
pub async fn list_for_ref(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  ref_ : String,
  per_page? : Int,
) -> ListCheckRunsResponse {
  let pp = per_page.unwrap_or(30)
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/commits/\{ref_}/check-runs?per_page=\{pp}",
  )
  @json.from_json(json)
}

///|
/// Get a single check run.
pub async fn get(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  check_run_id : Double,
) -> CheckRun {
  let id = check_run_id.to_int()
  let json = client.get_json("/repos/\{owner}/\{repo}/check-runs/\{id}")
  @json.from_json(json)
}

///|
/// A check suite.
pub struct CheckSuite {
  id : Double
  status : String
  conclusion : String?
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for CheckSuite with fn output(self, logger) {
  logger.write_string("{id: ")
  self.id.output(logger)
  logger.write_string(", status: ")
  self.status.output(logger)
  logger.write_string(", conclusion: ")
  self.conclusion.output(logger)
  logger.write_string("}")
}

///|
/// Response from listing check suites.
pub struct ListCheckSuitesResponse {
  total_count : Int
  check_suites : Array[CheckSuite]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for ListCheckSuitesResponse with fn output(self, logger) {
  logger.write_string("{total_count: ")
  self.total_count.output(logger)
  logger.write_string(", check_suites: ")
  self.check_suites.output(logger)
  logger.write_string("}")
}

///|
/// List check suites for a git reference.
pub async fn list_suites_for_ref(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  ref_ : String,
) -> ListCheckSuitesResponse {
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/commits/\{ref_}/check-suites",
  )
  @json.from_json(json)
}
