///|
/// Percent-encode a query string for URL use.
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
      buf.write_string(
        if hi < 10 {
          hi.to_string()
        } else {
          Char::from_int(hi - 10 + 65).to_string()
        },
      )
      buf.write_string(
        if lo < 10 {
          lo.to_string()
        } else {
          Char::from_int(lo - 10 + 65).to_string()
        },
      )
    }
  }
  buf.to_string()
}

///|
/// A search result item for issues/PRs.
pub struct IssueSearchItem {
  number : Int
  title : String
  state : String
  html_url : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for IssueSearchItem with output(self, logger) {
  logger.write_string("{number: ")
  self.number.output(logger)
  logger.write_string(", title: ")
  self.title.output(logger)
  logger.write_string(", state: ")
  self.state.output(logger)
  logger.write_string(", html_url: ")
  self.html_url.output(logger)
  logger.write_string("}")
}

///|
/// Response from searching issues/PRs.
pub struct IssueSearchResponse {
  total_count : Int
  incomplete_results : Bool
  items : Array[IssueSearchItem]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for IssueSearchResponse with output(self, logger) {
  logger.write_string("{total_count: ")
  self.total_count.output(logger)
  logger.write_string(", incomplete_results: ")
  self.incomplete_results.output(logger)
  logger.write_string(", items: ")
  self.items.output(logger)
  logger.write_string("}")
}

///|
/// Search issues and pull requests.
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

///|
/// A search result item for repositories.
pub struct RepoSearchItem {
  full_name : String
  html_url : String
  stargazers_count : Int
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for RepoSearchItem with output(self, logger) {
  logger.write_string("{full_name: ")
  self.full_name.output(logger)
  logger.write_string(", html_url: ")
  self.html_url.output(logger)
  logger.write_string(", stargazers_count: ")
  self.stargazers_count.output(logger)
  logger.write_string("}")
}

///|
/// Response from searching repositories.
pub struct RepoSearchResponse {
  total_count : Int
  incomplete_results : Bool
  items : Array[RepoSearchItem]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for RepoSearchResponse with output(self, logger) {
  logger.write_string("{total_count: ")
  self.total_count.output(logger)
  logger.write_string(", incomplete_results: ")
  self.incomplete_results.output(logger)
  logger.write_string(", items: ")
  self.items.output(logger)
  logger.write_string("}")
}

///|
/// Search repositories.
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

///|
/// A search result item for code.
pub struct CodeSearchItem {
  name : String
  path : String
  html_url : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for CodeSearchItem with output(self, logger) {
  logger.write_string("{name: ")
  self.name.output(logger)
  logger.write_string(", path: ")
  self.path.output(logger)
  logger.write_string(", html_url: ")
  self.html_url.output(logger)
  logger.write_string("}")
}

///|
/// Response from searching code.
pub struct CodeSearchResponse {
  total_count : Int
  incomplete_results : Bool
  items : Array[CodeSearchItem]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for CodeSearchResponse with output(self, logger) {
  logger.write_string("{total_count: ")
  self.total_count.output(logger)
  logger.write_string(", incomplete_results: ")
  self.incomplete_results.output(logger)
  logger.write_string(", items: ")
  self.items.output(logger)
  logger.write_string("}")
}

///|
/// Search code.
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
