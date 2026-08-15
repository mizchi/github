///|
/// A commit status.
pub struct Status {
  id : Double
  state : String
  target_url : String?
  description : String?
  context : String
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for Status with fn output(self, logger) {
  logger.write_string("{id: ")
  logger.write_string(@debug.to_string(self.id))
  logger.write_string(", state: ")
  logger.write_string(@debug.to_string(self.state))
  logger.write_string(", target_url: ")
  logger.write_string(@debug.to_string(self.target_url))
  logger.write_string(", description: ")
  logger.write_string(@debug.to_string(self.description))
  logger.write_string(", context: ")
  logger.write_string(@debug.to_string(self.context))
  logger.write_string("}")
}

///|
/// Combined status for a ref.
pub struct CombinedStatus {
  state : String
  total_count : Int
  statuses : Array[Status]
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for CombinedStatus with fn output(self, logger) {
  logger.write_string("{state: ")
  logger.write_string(@debug.to_string(self.state))
  logger.write_string(", total_count: ")
  logger.write_string(@debug.to_string(self.total_count))
  logger.write_string(", statuses: ")
  logger.write_string(@debug.to_string(self.statuses))
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
