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
      let c = @http.Client(self.base_url, headers=auth_headers(self.token))
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

///|
async fn check_response(conn : @http.Client, response : @http.Response) -> Unit {
  guard response.code >= 200 && response.code < 300 else {
    let body = conn.read_all()
    raise GitHubApiError(response.code, body.text())
  }
}

///| GET → JSON
pub async fn GitHubClient::get_json(self : GitHubClient, path : String) -> Json {
  let conn = self.ensure_conn()
  let response = conn.get(path, extra_headers=auth_headers(self.token))
  check_response(conn, response)
  let body = conn.read_all()
  body.json()
}

///| GET → raw bytes
pub async fn GitHubClient::get_binary(self : GitHubClient, path : String) -> Bytes {
  let conn = self.ensure_conn()
  let response = conn.get(path, extra_headers=auth_headers(self.token))
  check_response(conn, response)
  let body = conn.read_all()
  body.binary()
}

///| POST with JSON body → JSON response
pub async fn GitHubClient::post_json(
  self : GitHubClient,
  path : String,
  body : Json,
) -> Json {
  let conn = self.ensure_conn()
  let response = conn.post(path, body, extra_headers=auth_headers(self.token))
  check_response(conn, response)
  let resp_body = conn.read_all()
  resp_body.json()
}

///| PATCH with JSON body → JSON response
pub async fn GitHubClient::patch_json(
  self : GitHubClient,
  path : String,
  body : Json,
) -> Json {
  let conn = self.ensure_conn()
  let hdrs = auth_headers(self.token)
  conn.request(@http.Patch, path, extra_headers=hdrs)
  conn.write(body.stringify())
  let response = conn.end_request()
  check_response(conn, response)
  let resp_body = conn.read_all()
  resp_body.json()
}

///| DELETE → status code (204 = success)
pub async fn GitHubClient::delete(self : GitHubClient, path : String) -> Int {
  let conn = self.ensure_conn()
  let hdrs = auth_headers(self.token)
  conn.request(@http.Delete, path, extra_headers=hdrs)
  let response = conn.end_request()
  check_response(conn, response)
  conn.skip_response_body()
  response.code
}

///| PUT with JSON body → JSON response
pub async fn GitHubClient::put_json(
  self : GitHubClient,
  path : String,
  body : Json,
) -> Json {
  let conn = self.ensure_conn()
  let response = conn.put(path, body, extra_headers=auth_headers(self.token))
  check_response(conn, response)
  let resp_body = conn.read_all()
  resp_body.json()
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
