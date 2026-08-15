///|
/// Parse the Link header to extract the "next" page URL path.
///  Link: <https://api.github.com/repos/x/y/issues?page=2>; rel="next", ...
pub fn parse_next_link(headers : Map[String, String]) -> String? {
  let link = match headers.get("link") {
    Some(l) => l
    None => return None
  }
  let parts = link.split(",")
  for part in parts {
    let s = part.to_owned()
    if s.contains("rel=\"next\"") {
      // Extract URL between < and >
      let mut start = -1
      let mut end = -1
      for i, c in s {
        if c == '<' && start < 0 {
          start = i
        }
        if c == '>' && start >= 0 && end < 0 {
          end = i
        }
      }
      if start >= 0 && end > start {
        let url = s[start + 1:end].to_owned()
        let api_prefix = "https://api.github.com"
        if url.has_prefix(api_prefix) {
          return Some(url[api_prefix.length():].to_owned())
        }
        return Some(url)
      }
    }
  }
  None
}

///|
/// Paginate through all pages of a GET endpoint, collecting JSON arrays.
pub async fn GitHubClient::get_all_pages(
  self : GitHubClient,
  initial_path : String,
  extract_items : (Json) -> Array[Json],
  max_pages? : Int,
) -> Array[Json] {
  let limit = max_pages.unwrap_or(10)
  let all : Array[Json] = []
  let mut path = initial_path
  let mut page = 0
  while page < limit {
    let resp = self.get_response(path)
    let items = extract_items(resp.json)
    for item in items {
      all.push(item)
    }
    if items.is_empty() {
      break
    }
    match parse_next_link(resp.headers) {
      Some(next) => path = next
      None => break
    }
    page = page + 1
  }
  all
}
