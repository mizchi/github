///| Percent-encode a query string for URL use.
fn url_encode(s : String) -> String {
  let buf = StringBuilder::new()
  for c in s {
    if c == ' ' {
      buf.write_string("+")
    } else if (c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      (c >= '0' && c <= '9') ||
      c == '-' ||
      c == '_' ||
      c == '.' ||
      c == ':' {
      buf.write_char(c)
    } else {
      let code = c.to_int()
      buf.write_string("%")
      let hi = code / 16
      let lo = code % 16
      buf.write_string(if hi < 10 { hi.to_string() } else { Char::from_int(hi - 10 + 65).to_string() })
      buf.write_string(if lo < 10 { lo.to_string() } else { Char::from_int(lo - 10 + 65).to_string() })
    }
  }
  buf.to_string()
}

///| A search result item for issues/PRs.
pub struct IssueSearchItem {
  number : Int
  title : String
  state : String
  html_url : String
} derive(Show, Eq, FromJson, ToJson)

///| Response from searching issues/PRs.
pub struct IssueSearchResponse {
  total_count : Int
  incomplete_results : Bool
  items : Array[IssueSearchItem]
} derive(Show, Eq, FromJson, ToJson)

///| Search issues and pull requests.
///  q: search query (e.g. "repo:mizchi/flaker is:open label:bug")
pub async fn issues(
  client : @client.GitHubClient,
  q : String,
  sort? : String,
  order? : String,
  per_page? : Int,
) -> IssueSearchResponse {
  let pp = per_page.unwrap_or(30)
  let encoded = url_encode(q)
  let mut path = "/search/issues?per_page=\{pp}&q=\{encoded}"
  match sort {
    Some(s) => path = path + "&sort=\{s}"
    None => ()
  }
  match order {
    Some(o) => path = path + "&order=\{o}"
    None => ()
  }
  let json = client.get_json(path)
  @json.from_json(json)
}

///| A search result item for repositories.
pub struct RepoSearchItem {
  full_name : String
  html_url : String
  stargazers_count : Int
} derive(Show, Eq, FromJson, ToJson)

///| Response from searching repositories.
pub struct RepoSearchResponse {
  total_count : Int
  incomplete_results : Bool
  items : Array[RepoSearchItem]
} derive(Show, Eq, FromJson, ToJson)

///| Search repositories.
pub async fn repos(
  client : @client.GitHubClient,
  q : String,
  sort? : String,
  order? : String,
  per_page? : Int,
) -> RepoSearchResponse {
  let pp = per_page.unwrap_or(30)
  let encoded = url_encode(q)
  let mut path = "/search/repositories?per_page=\{pp}&q=\{encoded}"
  match sort {
    Some(s) => path = path + "&sort=\{s}"
    None => ()
  }
  match order {
    Some(o) => path = path + "&order=\{o}"
    None => ()
  }
  let json = client.get_json(path)
  @json.from_json(json)
}

///| A search result item for code.
pub struct CodeSearchItem {
  name : String
  path : String
  html_url : String
} derive(Show, Eq, FromJson, ToJson)

///| Response from searching code.
pub struct CodeSearchResponse {
  total_count : Int
  incomplete_results : Bool
  items : Array[CodeSearchItem]
} derive(Show, Eq, FromJson, ToJson)

///| Search code.
pub async fn code(
  client : @client.GitHubClient,
  q : String,
  sort? : String,
  order? : String,
  per_page? : Int,
) -> CodeSearchResponse {
  let pp = per_page.unwrap_or(30)
  let encoded = url_encode(q)
  let mut path = "/search/code?per_page=\{pp}&q=\{encoded}"
  match sort {
    Some(s) => path = path + "&sort=\{s}"
    None => ()
  }
  match order {
    Some(o) => path = path + "&order=\{o}"
    None => ()
  }
  let json = client.get_json(path)
  @json.from_json(json)
}
