///| An issue.
pub struct Issue {
  id : Int
  number : Int
  title : String
  body : String?
  state : String
  html_url : String
} derive(Show, Eq, FromJson, ToJson)

///| List issues for a repository.
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

///| Get a single issue.
pub async fn get(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
) -> Issue {
  let json = client.get_json("/repos/\{owner}/\{repo}/issues/\{number}")
  @json.from_json(json)
}

///| Create an issue.
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

///| Issue comment.
pub struct Comment {
  id : Int
  body : String
  html_url : String
} derive(Show, Eq, FromJson, ToJson)

///| List comments on an issue.
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

///| Add a comment to an issue.
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
