///| A pull request.
pub struct PullRequest {
  id : Double
  number : Int
  title : String
  body : String?
  state : String
  html_url : String
  head_ref : String?
  base_ref : String?
  mergeable : Bool?
} derive(Show, Eq, FromJson, ToJson)

///| List pull requests.
pub async fn list(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  state? : String,
  per_page? : Int,
) -> Array[PullRequest] {
  let s = state.unwrap_or("open")
  let pp = per_page.unwrap_or(30)
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/pulls?state=\{s}&per_page=\{pp}",
  )
  @json.from_json(json)
}

///| Get a single pull request.
pub async fn get(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
) -> PullRequest {
  let json = client.get_json("/repos/\{owner}/\{repo}/pulls/\{number}")
  @json.from_json(json)
}

///| Create a pull request.
pub async fn create(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  title : String,
  head : String,
  base : String,
  body? : String,
) -> PullRequest {
  let obj : Map[String, Json] = {
    "title": title.to_json(),
    "head": head.to_json(),
    "base": base.to_json(),
  }
  match body {
    Some(b) => obj.set("body", b.to_json())
    None => ()
  }
  let json = client.post_json("/repos/\{owner}/\{repo}/pulls", obj.to_json())
  @json.from_json(json)
}

///| Update a pull request.
pub async fn update(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
  title? : String,
  body? : String,
  state? : String,
  base? : String,
) -> PullRequest {
  let obj : Map[String, Json] = {}
  match title { Some(t) => obj.set("title", t.to_json()); None => () }
  match body { Some(b) => obj.set("body", b.to_json()); None => () }
  match state { Some(s) => obj.set("state", s.to_json()); None => () }
  match base { Some(b) => obj.set("base", b.to_json()); None => () }
  let json = client.patch_json("/repos/\{owner}/\{repo}/pulls/\{number}", obj.to_json())
  @json.from_json(json)
}

///| A review on a pull request.
pub struct Review {
  id : Double
  state : String
  body : String?
} derive(Show, Eq, FromJson, ToJson)

///| List reviews on a pull request.
pub async fn list_reviews(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
) -> Array[Review] {
  let json = client.get_json("/repos/\{owner}/\{repo}/pulls/\{number}/reviews")
  @json.from_json(json)
}

///| Request reviewers for a pull request.
pub async fn request_reviewers(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
  reviewers : Array[String],
) -> Json {
  let obj : Map[String, Json] = { "reviewers": reviewers.to_json() }
  client.post_json("/repos/\{owner}/\{repo}/pulls/\{number}/requested_reviewers", obj.to_json())
}

///| File changed in a pull request.
pub struct PullFile {
  filename : String
  status : String
  additions : Int
  deletions : Int
} derive(Show, Eq, FromJson, ToJson)

///| List files changed in a pull request.
pub async fn list_files(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
) -> Array[PullFile] {
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/pulls/\{number}/files",
  )
  @json.from_json(json)
}

///| Merge a pull request.
pub async fn merge(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  number : Int,
  merge_method? : String,
) -> Json {
  let obj : Map[String, Json] = {}
  match merge_method {
    Some(m) => obj.set("merge_method", m.to_json())
    None => ()
  }
  client.put_json(
    "/repos/\{owner}/\{repo}/pulls/\{number}/merge",
    obj.to_json(),
  )
}
