///| Repository information.
pub struct Repository {
  id : Double
  name : String
  full_name : String
  default_branch : String
  html_url : String
  clone_url : String
} derive(Show, Eq, FromJson, ToJson)

///| Get a repository.
pub async fn get(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
) -> Repository {
  let json = client.get_json("/repos/\{owner}/\{repo}")
  @json.from_json(json)
}

///| File content from a repository.
pub struct Content {
  name : String
  path : String
  sha : String
  content : String?
  encoding : String?
} derive(Show, Eq, FromJson, ToJson)

///| Get file content at a path.
pub async fn get_content(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  path : String,
  ref_? : String,
) -> Content {
  let mut url = "/repos/\{owner}/\{repo}/contents/\{path}"
  match ref_ {
    Some(r) => url = url + "?ref=\{r}"
    None => ()
  }
  let json = client.get_json(url)
  @json.from_json(json)
}

///| Branch information.
pub struct Branch {
  name : String
} derive(Show, Eq, FromJson, ToJson)

///| A git tag.
pub struct Tag {
  name : String
  zipball_url : String
  tarball_url : String
} derive(Show, Eq, FromJson, ToJson)

///| List tags.
pub async fn list_tags(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  per_page? : Int,
) -> Array[Tag] {
  let pp = per_page.unwrap_or(30)
  let json = client.get_json("/repos/\{owner}/\{repo}/tags?per_page=\{pp}")
  @json.from_json(json)
}

///| A release.
pub struct Release {
  id : Double
  tag_name : String
  name : String?
  body : String?
  draft : Bool
  prerelease : Bool
  html_url : String
} derive(Show, Eq, FromJson, ToJson)

///| List releases.
pub async fn list_releases(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  per_page? : Int,
) -> Array[Release] {
  let pp = per_page.unwrap_or(30)
  let json = client.get_json("/repos/\{owner}/\{repo}/releases?per_page=\{pp}")
  @json.from_json(json)
}

///| Get the latest release.
pub async fn get_latest_release(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
) -> Release {
  let json = client.get_json("/repos/\{owner}/\{repo}/releases/latest")
  @json.from_json(json)
}

///| Create a release.
pub async fn create_release(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  tag_name : String,
  name? : String,
  body? : String,
  draft? : Bool,
  prerelease? : Bool,
) -> Release {
  let obj : Map[String, Json] = { "tag_name": tag_name.to_json() }
  match name { Some(n) => obj.set("name", n.to_json()); None => () }
  match body { Some(b) => obj.set("body", b.to_json()); None => () }
  match draft { Some(d) => obj.set("draft", d.to_json()); None => () }
  match prerelease { Some(p) => obj.set("prerelease", p.to_json()); None => () }
  let json = client.post_json("/repos/\{owner}/\{repo}/releases", obj.to_json())
  @json.from_json(json)
}

///| A file changed in a comparison.
pub struct CompareFile {
  filename : String
  status : String
  additions : Int
  deletions : Int
} derive(Show, Eq, FromJson, ToJson)

///| Comparison between two refs.
pub struct Comparison {
  status : String
  ahead_by : Int
  behind_by : Int
  total_commits : Int
  files : Array[CompareFile]
} derive(Show, Eq, FromJson, ToJson)

///| Compare two commits/branches/tags.
pub async fn compare(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  base : String,
  head : String,
) -> Comparison {
  let json = client.get_json("/repos/\{owner}/\{repo}/compare/\{base}...\{head}")
  @json.from_json(json)
}

///| List branches.
pub async fn list_branches(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
) -> Array[Branch] {
  let json = client.get_json("/repos/\{owner}/\{repo}/branches")
  @json.from_json(json)
}
