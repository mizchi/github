///|
/// GitHub REST API client.
pub struct GitHubClient {
  token : String
  base_url : String
  mut conn : @http.Client?
}

///|
pub fn GitHubClient::new(token : String, base_url? : String) -> GitHubClient {
  { token, base_url: base_url.unwrap_or("https://api.github.com"), conn: None, }
}

///|
/// Create a fresh connection (closes existing one).
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
fn base_headers(token : String) -> Map[@http.CaseInsensitiveString, String] {
  let hdrs : Map[@http.CaseInsensitiveString, String] = {
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "User-Agent": "mizchi-github-mbt/0.1.0",
  }
  if token != "" {
    hdrs.set("Authorization", "Bearer \{token}")
  }
  hdrs
}

///|
/// Response with headers, for pagination/rate-limit inspection.
pub struct ApiResponse {
  json : Json
  status : Int
  headers : Map[String, String]
}

///|
pub impl Show for ApiResponse with fn output(self, logger) {
  logger.write_string("{json: ")
  logger.write_string(@debug.to_string(self.json))
  logger.write_string(", status: ")
  logger.write_string(self.status.to_string())
  logger.write_string(", headers: ")
  logger.write_string(@debug.to_string(self.headers))
  logger.write_string("}")
}

///|
/// Check response and raise on error.
async fn GitHubClient::check(
  self : GitHubClient,
  conn : @http.Client,
  response : @http.Response,
) -> Unit {
  // Rate limit: 429 or 403 with retry-after
  if response.code == 429 ||
    (response.code == 403 && response.headers.contains("retry-after")) {
    let body = conn.read_all()
    self.conn = None
    raise RateLimitError(response.code, body.text())
  }
  guard response.code >= 200 && response.code < 300 else {
    let body = conn.read_all()
    self.conn = None
    raise GitHubApiError(response.code, body.text())
  }
}

///|
/// GET → JSON
pub async fn GitHubClient::get_json(self : GitHubClient, path : String) -> Json {
  let conn = self.fresh_conn()
  let response = conn.get(path)
  self.check(conn, response)
  conn.read_all().json()
}

///|
/// GET → JSON with full response (headers for pagination/rate-limit).
pub async fn GitHubClient::get_response(
  self : GitHubClient,
  path : String,
) -> ApiResponse {
  let conn = self.fresh_conn()
  let response = conn.get(path)
  self.check(conn, response)
  let json = conn.read_all().json()
  let headers : Map[String, String] = Map::new()
  for k, v in response.headers {
    headers.set(k.to_string(), v)
  }
  { json, status: response.code, headers, }
}

///|
/// GET → raw bytes (follows 302 redirects for artifact download).
pub async fn GitHubClient::get_binary(
  self : GitHubClient,
  path : String,
) -> Bytes {
  let conn = self.fresh_conn()
  let response = conn.get(path)
  // Follow redirect
  if response.code == 302 {
    match response.headers.get("location") {
      Some(url) => {
        ignore(conn.read_all())
        let (resp, body) = @http.get(url)
        guard resp.code >= 200 && resp.code < 300 else {
          raise GitHubApiError(resp.code, "redirect failed")
        }
        return body.binary()
      }
      None => raise GitHubApiError(302, "redirect without location")
    }
  }
  self.check(conn, response)
  conn.read_all().binary()
}

///|
/// POST with JSON body → JSON response
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

///|
/// POST with raw bytes body → JSON response (for asset upload).
pub async fn GitHubClient::post_binary(
  self : GitHubClient,
  url : String,
  data : Bytes,
  content_type : String,
) -> Json {
  let conn = self.fresh_conn()
  let hdrs : Map[@http.CaseInsensitiveString, String] = {
    "Content-Type": content_type,
  }
  conn.request(@http.Post, url, extra_headers=hdrs)
  conn.write(data)
  let response = conn.end_request()
  self.check(conn, response)
  conn.read_all().json()
}

///|
/// PATCH with JSON body → JSON response
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

///|
/// DELETE → status code (204 = success)
pub async fn GitHubClient::delete(self : GitHubClient, path : String) -> Int {
  let conn = self.fresh_conn()
  conn.request(@http.Delete, path)
  let response = conn.end_request()
  self.check(conn, response)
  ignore(conn.read_all())
  response.code
}

///|
/// PUT with JSON body → JSON response
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
} derive(ToJson)

///|
pub impl Show for GitHubApiError with fn output(self, logger) {
  let GitHubApiError(code, msg) = self
  logger.write_string("GitHubApiError(")
  logger.write_string(code.to_string())
  logger.write_string(", ")
  logger.write_string(msg)
  logger.write_string(")")
}

///|
pub suberror RateLimitError {
  RateLimitError(Int, String)
} derive(ToJson)

///|
pub impl Show for RateLimitError with fn output(self, logger) {
  let RateLimitError(code, msg) = self
  logger.write_string("RateLimitError(")
  logger.write_string(code.to_string())
  logger.write_string(", ")
  logger.write_string(msg)
  logger.write_string(")")
}
