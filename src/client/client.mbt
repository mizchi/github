///| GitHub REST API client.
pub struct GitHubClient {
  token : String
  base_url : String
  mut conn : @http.Client?
}

///|
pub fn GitHubClient::new(token : String) -> GitHubClient {
  { token, base_url: "https://api.github.com", conn: None }
}

///|
async fn GitHubClient::ensure_conn(self : GitHubClient) -> @http.Client {
  match self.conn {
    Some(c) => c
    None => {
      let c = @http.Client(
        self.base_url,
        headers=auth_headers(self.token),
      )
      self.conn = Some(c)
      c
    }
  }
}

///|
fn auth_headers(token : String) -> Map[String, String] {
  {
    "Authorization": "Bearer \{token}",
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "User-Agent": "mizchi-github-mbt/0.1.0",
  }
}

///| Make a GET request and return the response body as JSON.
pub async fn GitHubClient::get_json(
  self : GitHubClient,
  path : String,
) -> Json {
  let conn = self.ensure_conn()
  let response = conn.get(path, extra_headers=auth_headers(self.token))
  guard response.code >= 200 && response.code < 300 else {
    let body = conn.read_all()
    raise GitHubApiError(response.code, body.text())
  }
  let body = conn.read_all()
  body.json()
}

///| Make a GET request and return raw bytes.
pub async fn GitHubClient::get_binary(
  self : GitHubClient,
  path : String,
) -> Bytes {
  let conn = self.ensure_conn()
  let response = conn.get(path, extra_headers=auth_headers(self.token))
  guard response.code >= 200 && response.code < 300 else {
    let body = conn.read_all()
    raise GitHubApiError(response.code, body.text())
  }
  let body = conn.read_all()
  body.binary()
}

///|
pub fn GitHubClient::close(self : GitHubClient) -> Unit {
  match self.conn {
    Some(c) => c.close()
    None => ()
  }
  self.conn = None
}

///|
pub suberror GitHubApiError {
  GitHubApiError(Int, String)
} derive(Show, ToJson)
