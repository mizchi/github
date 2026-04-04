///| GitHub REST API client.
pub struct GitHubClient {
  token : String
  base_url : String
  mut conn : @http.Client?
}

///|
pub fn GitHubClient::new(token : String, base_url? : String) -> GitHubClient {
  {
    token,
    base_url: base_url.unwrap_or("https://api.github.com"),
    conn: None,
  }
}

///| Create a fresh connection (closes existing one).
async fn GitHubClient::fresh_conn(self : GitHubClient) -> @http.Client {
  match self.conn {
    Some(c) => c.close()
    None => ()
  }
  let c = @http.Client(self.base_url, headers=base_headers(self.token))
  self.conn = Some(c)
  c
}

///|
fn base_headers(token : String) -> Map[String, String] {
  let hdrs : Map[String, String] = {
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "User-Agent": "mizchi-github-mbt/0.1.0",
  }
  if token != "" {
    hdrs.set("Authorization", "Bearer \{token}")
  }
  hdrs
}

///| Check response and raise on error. Returns nothing — caller reads body after this.
async fn GitHubClient::check(
  self : GitHubClient,
  conn : @http.Client,
  response : @http.Response,
) -> Unit {
  guard response.code >= 200 && response.code < 300 else {
    let body = conn.read_all()
    self.conn = None
    raise GitHubApiError(response.code, body.text())
  }
}

///| GET → JSON
pub async fn GitHubClient::get_json(self : GitHubClient, path : String) -> Json {
  let conn = self.fresh_conn()
  let response = conn.get(path)
  self.check(conn, response)
  conn.read_all().json()
}

///| GET → raw bytes
pub async fn GitHubClient::get_binary(
  self : GitHubClient,
  path : String,
) -> Bytes {
  let conn = self.fresh_conn()
  let response = conn.get(path)
  self.check(conn, response)
  conn.read_all().binary()
}

///| POST with JSON body → JSON response
pub async fn GitHubClient::post_json(
  self : GitHubClient,
  path : String,
  body : Json,
) -> Json {
  let conn = self.fresh_conn()
  let response = conn.post(path, body)
  self.check(conn, response)
  conn.read_all().json()
}

///| PATCH with JSON body → JSON response
pub async fn GitHubClient::patch_json(
  self : GitHubClient,
  path : String,
  body : Json,
) -> Json {
  let conn = self.fresh_conn()
  conn.request(@http.Patch, path)
  conn.write(body.stringify())
  let response = conn.end_request()
  self.check(conn, response)
  conn.read_all().json()
}

///| DELETE → status code (204 = success)
pub async fn GitHubClient::delete(
  self : GitHubClient,
  path : String,
) -> Int {
  let conn = self.fresh_conn()
  conn.request(@http.Delete, path)
  let response = conn.end_request()
  self.check(conn, response)
  conn.skip_response_body()
  response.code
}

///| PUT with JSON body → JSON response
pub async fn GitHubClient::put_json(
  self : GitHubClient,
  path : String,
  body : Json,
) -> Json {
  let conn = self.fresh_conn()
  let response = conn.put(path, body)
  self.check(conn, response)
  conn.read_all().json()
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
