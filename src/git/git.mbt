///| A git reference (flattened from nested GitHub response).
pub struct Ref {
  ref_ : String
  object_sha : String
  object_type : String
} derive(Show, Eq)

///|
pub impl @json.FromJson for Ref with from_json(json, path) {
  guard json.as_object() is Some(obj) else {
    raise @json.JsonDecodeError((path, "expected object for Ref"))
  }
  let ref_ = match obj.get("ref") {
    Some(Json::String(s)) => s
    _ => raise @json.JsonDecodeError((path, "missing ref"))
  }
  let inner = match obj.get("object") {
    Some(Json::Object(o)) => o
    _ => raise @json.JsonDecodeError((path, "missing object"))
  }
  let object_sha = match inner.get("sha") {
    Some(Json::String(s)) => s
    _ => raise @json.JsonDecodeError((path, "missing sha"))
  }
  let object_type = match inner.get("type") {
    Some(Json::String(s)) => s
    _ => raise @json.JsonDecodeError((path, "missing type"))
  }
  { ref_, object_sha, object_type }
}

///|
pub impl ToJson for Ref with to_json(self) {
  let inner : Map[String, Json] = {
    "sha": self.object_sha.to_json(),
    "type": self.object_type.to_json(),
  }
  let obj : Map[String, Json] = {
    "ref": self.ref_.to_json(),
    "object": inner.to_json(),
  }
  obj.to_json()
}

///| Get a reference (e.g. "heads/main").
pub async fn get_ref(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  ref_ : String,
) -> Ref {
  let json = client.get_json("/repos/\{owner}/\{repo}/git/ref/\{ref_}")
  @json.from_json(json)
}

///| Create a reference (e.g. "refs/heads/new-branch").
pub async fn create_ref(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  ref_ : String,
  sha : String,
) -> Ref {
  let obj : Map[String, Json] = {
    "ref": ref_.to_json(),
    "sha": sha.to_json(),
  }
  let json = client.post_json("/repos/\{owner}/\{repo}/git/refs", obj.to_json())
  @json.from_json(json)
}

///| Delete a reference (e.g. "heads/branch-name").
pub async fn delete_ref(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  ref_ : String,
) -> Unit {
  let _ = client.delete("/repos/\{owner}/\{repo}/git/refs/\{ref_}")
}

///| A git commit.
pub struct Commit {
  sha : String
  message : String
} derive(Show, Eq, FromJson, ToJson)

///| Get a commit.
pub async fn get_commit(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  sha : String,
) -> Commit {
  let json = client.get_json("/repos/\{owner}/\{repo}/git/commits/\{sha}")
  @json.from_json(json)
}

///| A tree entry.
pub struct TreeEntry {
  path : String
  mode : String
  sha : String
} derive(Show, Eq, FromJson, ToJson)

///| Tree response.
pub struct Tree {
  sha : String
  tree : Array[TreeEntry]
} derive(Show, Eq, FromJson, ToJson)

///| Get a tree.
pub async fn get_tree(
  client : @client.GitHubClient,
  owner : String,
  repo : String,
  sha : String,
  recursive? : Bool,
) -> Tree {
  let mut url = "/repos/\{owner}/\{repo}/git/trees/\{sha}"
  match recursive {
    Some(true) => url = url + "?recursive=1"
    _ => ()
  }
  let json = client.get_json(url)
  @json.from_json(json)
}
