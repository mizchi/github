///|
/// A commit status.
pub struct Status {
  id : Double
  state : String
  target_url : String?
  description : String?
  context : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Status with fn output(self, logger) {
  logger.write_string("{id: ")
  self.id.output(logger)
  logger.write_string(", state: ")
  self.state.output(logger)
  logger.write_string(", target_url: ")
  self.target_url.output(logger)
  logger.write_string(", description: ")
  self.description.output(logger)
  logger.write_string(", context: ")
  self.context.output(logger)
  logger.write_string("}")
}

///|
/// Combined status for a ref.
pub struct CombinedStatus {
  state : String
  total_count : Int
  statuses : Array[Status]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for CombinedStatus with fn output(self, logger) {
  logger.write_string("{state: ")
  self.state.output(logger)
  logger.write_string(", total_count: ")
  self.total_count.output(logger)
  logger.write_string(", statuses: ")
  self.statuses.output(logger)
  logger.write_string("}")
}

///|
/// Get the combined status for a ref (branch, tag, or SHA).
pub async fn get_combined(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  ref_ : String,
) -> CombinedStatus {
  let json = client.get_json("/repos/\{owner}/\{repo}/commits/\{ref_}/status")
  @json.from_json(json)
}

///|
/// List statuses for a ref.
pub async fn list(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  ref_ : String,
  per_page? : Int,
) -> Array[Status] {
  let pp = per_page.unwrap_or(30)
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/commits/\{ref_}/statuses?per_page=\{pp}",
  )
  @json.from_json(json)
}

///|
/// Create a commit status.
pub async fn create(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  sha : String,
  state : String,
  target_url? : String,
  description? : String,
  context? : String,
) -> Status {
  let obj : Map[String, Json] = { "state": state.to_json() }
  match target_url {
    Some(u) => obj.set("target_url", u.to_json())
    None => ()
  }
  match description {
    Some(d) => obj.set("description", d.to_json())
    None => ()
  }
  match context {
    Some(c) => obj.set("context", c.to_json())
    None => ()
  }
  let json = client.post_json(
    "/repos/\{owner}/\{repo}/statuses/\{sha}",
    obj.to_json(),
  )
  @json.from_json(json)
}
