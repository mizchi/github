///|
/// An issue.
pub struct Issue {
  id : Double
  number : Int
  title : String
  body : String?
  state : String
  html_url : String
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for Issue with fn output(self, logger) {
  logger.write_string("{id: ")
  logger.write_string(@debug.to_string(self.id))
  logger.write_string(", number: ")
  logger.write_string(@debug.to_string(self.number))
  logger.write_string(", title: ")
  logger.write_string(@debug.to_string(self.title))
  logger.write_string(", body: ")
  logger.write_string(@debug.to_string(self.body))
  logger.write_string(", state: ")
  logger.write_string(@debug.to_string(self.state))
  logger.write_string(", html_url: ")
  logger.write_string(@debug.to_string(self.html_url))
  logger.write_string("}")
}

///|
/// List issues for a repository.
pub async fn list(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  state? : String,
  per_page? : Int,
) -> Array[Issue] {
  let s = state.unwrap_or("open")
  let pp = per_page.unwrap_or(30)
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/issues?state=\{s}&per_page=\{pp}",
  )
  @json.from_json(json)
}

///|
/// Get a single issue.
pub async fn get(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
) -> Issue {
  let json = client.get_json("/repos/\{owner}/\{repo}/issues/\{number}")
  @json.from_json(json)
}

///|
/// Create an issue.
pub async fn create(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  title : String,
  body? : String,
) -> Issue {
  let obj : Map[String, Json] = { "title": title.to_json() }
  match body {
    Some(b) => obj.set("body", b.to_json())
    None => ()
  }
  let json = client.post_json("/repos/\{owner}/\{repo}/issues", obj.to_json())
  @json.from_json(json)
}

///|
/// Update an issue (title, body, state).
pub async fn update(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
  title? : String,
  body? : String,
  state? : String,
) -> Issue {
  let obj : Map[String, Json] = Map([])
  match title {
    Some(t) => obj.set("title", t.to_json())
    None => ()
  }
  match body {
    Some(b) => obj.set("body", b.to_json())
    None => ()
  }
  match state {
    Some(s) => obj.set("state", s.to_json())
    None => ()
  }
  let json = client.patch_json(
    "/repos/\{owner}/\{repo}/issues/\{number}",
    obj.to_json(),
  )
  @json.from_json(json)
}

///|
/// Add labels to an issue.
pub async fn add_labels(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
  labels : Array[String],
) -> Json {
  let obj : Map[String, Json] = { "labels": labels.to_json() }
  client.post_json(
    "/repos/\{owner}/\{repo}/issues/\{number}/labels",
    obj.to_json(),
  )
}

///|
/// Issue comment.
pub struct Comment {
  id : Double
  body : String
  html_url : String
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for Comment with fn output(self, logger) {
  logger.write_string("{id: ")
  logger.write_string(@debug.to_string(self.id))
  logger.write_string(", body: ")
  logger.write_string(@debug.to_string(self.body))
  logger.write_string(", html_url: ")
  logger.write_string(@debug.to_string(self.html_url))
  logger.write_string("}")
}

///|
/// List comments on an issue.
pub async fn list_comments(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
) -> Array[Comment] {
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/issues/\{number}/comments",
  )
  @json.from_json(json)
}

///|
/// Add a comment to an issue.
pub async fn create_comment(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
  body : String,
) -> Comment {
  let obj : Map[String, Json] = { "body": body.to_json() }
  let json = client.post_json(
    "/repos/\{owner}/\{repo}/issues/\{number}/comments",
    obj.to_json(),
  )
  @json.from_json(json)
}
