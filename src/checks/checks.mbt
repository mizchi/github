///| A check run.
pub struct CheckRun {
  id : Double
  name : String
  status : String
  conclusion : String?
  html_url : String
} derive(Show, Eq, FromJson, ToJson)

///| Response from listing check runs.
pub struct ListCheckRunsResponse {
  total_count : Int
  check_runs : Array[CheckRun]
} derive(Show, Eq, FromJson, ToJson)

///| List check runs for a git reference (branch, tag, or SHA).
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

///| Get a single check run.
pub async fn get(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  check_run_id : Double,
) -> CheckRun {
  let id = check_run_id.to_int()
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/check-runs/\{id}",
  )
  @json.from_json(json)
}

///| A check suite.
pub struct CheckSuite {
  id : Double
  status : String
  conclusion : String?
} derive(Show, Eq, FromJson, ToJson)

///| Response from listing check suites.
pub struct ListCheckSuitesResponse {
  total_count : Int
  check_suites : Array[CheckSuite]
} derive(Show, Eq, FromJson, ToJson)

///| List check suites for a git reference.
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
