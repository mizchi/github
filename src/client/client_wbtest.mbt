///|
#cfg(target="native")
async test "get_json returns parsed JSON from mock server" {
  let server = @http.Server(@socket.Addr::new(0x7F000001, 0))
  let port = server.addr().port()
  @async.with_task_group(
    async fn(group) {
      group.spawn_bg(
        async fn() {
          server.run_forever(
            async fn(req, _reader, conn) {
              if req.path == "/repos/test/repo" {
                conn.send_response(200, "OK")
                conn.write("{\"id\":1,\"name\":\"repo\"}")
                conn.end_response()
              } else {
                conn.send_response(404, "Not Found")
                conn.write("{\"message\":\"Not Found\"}")
                conn.end_response()
              }
            },
            allow_failure=true,
          )
        },
      )
      let client = GitHubClient::new("test-token", base_url="http://127.0.0.1:\{port}")
      defer client.close()
      let json = client.get_json("/repos/test/repo")
      guard json.as_object() is Some(obj) else { fail!("expected object") }
      guard obj.get("name") is Some(Json::String(name)) else {
        fail!("expected name field")
      }
      assert_eq!(name, "repo")
      server.close()
    },
  )
}

///|
#cfg(target="native")
async test "get_json raises GitHubApiError on 404" {
  let server = @http.Server(@socket.Addr::new(0x7F000001, 0))
  let port = server.addr().port()
  @async.with_task_group(
    async fn(group) {
      group.spawn_bg(
        async fn() {
          server.run_forever(
            async fn(_req, _reader, conn) {
              conn.send_response(404, "Not Found")
              conn.write("{\"message\":\"Not Found\"}")
              conn.end_response()
            },
            allow_failure=true,
          )
        },
      )
      let client = GitHubClient::new("test-token", base_url="http://127.0.0.1:\{port}")
      defer client.close()
      let mut caught = false
      try {
        let _ = client.get_json("/missing")

      } catch {
        GitHubApiError(code, _) => {
          assert_eq!(code, 404)
          caught = true
        }
        _ => fail!("unexpected error type")
      }
      assert_true!(caught)
      server.close()
    },
  )
}

///|
#cfg(target="native")
async test "post_json sends body and returns response" {
  let server = @http.Server(@socket.Addr::new(0x7F000001, 0))
  let port = server.addr().port()
  @async.with_task_group(
    async fn(group) {
      group.spawn_bg(
        async fn() {
          server.run_forever(
            async fn(req, _reader, conn) {
              if req.meth == @http.Post {
                conn.send_response(201, "Created")
                conn.write("{\"ok\":true}")
                conn.end_response()
              } else {
                conn.send_response(405, "Method Not Allowed")
                conn.end_response()
              }
            },
            allow_failure=true,
          )
        },
      )
      let client = GitHubClient::new("test-token", base_url="http://127.0.0.1:\{port}")
      defer client.close()
      let body : Map[String, Json] = { "title": "test".to_json() }
      let json = client.post_json("/test", body.to_json())
      guard json.as_object() is Some(obj) else { fail!("expected object") }
      assert_true!(obj.contains("ok"))
      server.close()
    },
  )
}
