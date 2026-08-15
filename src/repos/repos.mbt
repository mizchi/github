///|
/// Repository information.
pub struct Repository {
  id : Double
  name : String
  full_name : String
  default_branch : String
  html_url : String
  clone_url : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Repository with fn output(self, logger) {
  logger.write_string("{id: ")
  self.id.output(logger)
  logger.write_string(", name: ")
  self.name.output(logger)
  logger.write_string(", full_name: ")
  self.full_name.output(logger)
  logger.write_string(", default_branch: ")
  self.default_branch.output(logger)
  logger.write_string(", html_url: ")
  self.html_url.output(logger)
  logger.write_string(", clone_url: ")
  self.clone_url.output(logger)
  logger.write_string("}")
}

///|
/// Get a repository.
pub async fn get(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
) -> Repository {
  let json = client.get_json("/repos/\{owner}/\{repo}")
  @json.from_json(json)
}

///|
/// File content from a repository.
pub struct Content {
  name : String
  path : String
  sha : String
  content : String?
  encoding : String?
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Content with fn output(self, logger) {
  logger.write_string("{name: ")
  self.name.output(logger)
  logger.write_string(", path: ")
  self.path.output(logger)
  logger.write_string(", sha: ")
  self.sha.output(logger)
  logger.write_string(", content: ")
  self.content.output(logger)
  logger.write_string(", encoding: ")
  self.encoding.output(logger)
  logger.write_string("}")
}

///|
/// Get file content at a path.
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

///|
/// Branch information.
pub struct Branch {
  name : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Branch with fn output(self, logger) {
  logger.write_string("{name: ")
  self.name.output(logger)
  logger.write_string("}")
}

///|
/// A git tag.
pub struct Tag {
  name : String
  zipball_url : String
  tarball_url : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Tag with fn output(self, logger) {
  logger.write_string("{name: ")
  self.name.output(logger)
  logger.write_string(", zipball_url: ")
  self.zipball_url.output(logger)
  logger.write_string(", tarball_url: ")
  self.tarball_url.output(logger)
  logger.write_string("}")
}

///|
/// List tags.
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

///|
/// A release.
pub struct Release {
  id : Double
  tag_name : String
  name : String?
  body : String?
  draft : Bool
  prerelease : Bool
  html_url : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Release with fn output(self, logger) {
  logger.write_string("{id: ")
  self.id.output(logger)
  logger.write_string(", tag_name: ")
  self.tag_name.output(logger)
  logger.write_string(", name: ")
  self.name.output(logger)
  logger.write_string(", body: ")
  self.body.output(logger)
  logger.write_string(", draft: ")
  self.draft.output(logger)
  logger.write_string(", prerelease: ")
  self.prerelease.output(logger)
  logger.write_string(", html_url: ")
  self.html_url.output(logger)
  logger.write_string("}")
}

///|
/// List releases.
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

///|
/// Get the latest release.
pub async fn get_latest_release(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
) -> Release {
  let json = client.get_json("/repos/\{owner}/\{repo}/releases/latest")
  @json.from_json(json)
}

///|
/// Create a release.
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
  match name {
    Some(n) => obj.set("name", n.to_json())
    None => ()
  }
  match body {
    Some(b) => obj.set("body", b.to_json())
    None => ()
  }
  match draft {
    Some(d) => obj.set("draft", d.to_json())
    None => ()
  }
  match prerelease {
    Some(p) => obj.set("prerelease", p.to_json())
    None => ()
  }
  let json = client.post_json("/repos/\{owner}/\{repo}/releases", obj.to_json())
  @json.from_json(json)
}

///|
/// A file changed in a comparison.
pub struct CompareFile {
  filename : String
  status : String
  additions : Int
  deletions : Int
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for CompareFile with fn output(self, logger) {
  logger.write_string("{filename: ")
  self.filename.output(logger)
  logger.write_string(", status: ")
  self.status.output(logger)
  logger.write_string(", additions: ")
  self.additions.output(logger)
  logger.write_string(", deletions: ")
  self.deletions.output(logger)
  logger.write_string("}")
}

///|
/// Comparison between two refs.
pub struct Comparison {
  status : String
  ahead_by : Int
  behind_by : Int
  total_commits : Int
  files : Array[CompareFile]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Comparison with fn output(self, logger) {
  logger.write_string("{status: ")
  self.status.output(logger)
  logger.write_string(", ahead_by: ")
  self.ahead_by.output(logger)
  logger.write_string(", behind_by: ")
  self.behind_by.output(logger)
  logger.write_string(", total_commits: ")
  self.total_commits.output(logger)
  logger.write_string(", files: ")
  self.files.output(logger)
  logger.write_string("}")
}

///|
/// Compare two commits/branches/tags.
pub async fn compare(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  base : String,
  head : String,
) -> Comparison {
  let json = client.get_json(
    "/repos/\{owner}/\{repo}/compare/\{base}...\{head}",
  )
  @json.from_json(json)
}

///|
/// List branches.
pub async fn list_branches(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
) -> Array[Branch] {
  let json = client.get_json("/repos/\{owner}/\{repo}/branches")
  @json.from_json(json)
}
