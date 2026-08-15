// Integration test using httpbin.org.
// Cannot use mock server due to TCC 5MB limit (moonbitlang/async#328):
// @http.Server + @http.Client in same binary exceeds the limit.

///|
#cfg(target="native")
async test "get_json fetches real endpoint" {
  let (response, body) = @http.get("https://httpbin.org/get")
  assert_eq(response.code, 200)
  let json = body.json()
  guard json is Json::Object(obj) else { fail("expected object") }
  assert_true(obj.contains("headers"))
}
