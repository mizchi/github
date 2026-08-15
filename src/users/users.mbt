///|
/// Authenticated user or public user profile.
pub struct User {
  id : Double
  login : String
  name : String?
  email : String?
  avatar_url : String
  html_url : String
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for User with output(self, logger) {
  logger.write_string("{id: ")
  self.id.output(logger)
  logger.write_string(", login: ")
  self.login.output(logger)
  logger.write_string(", name: ")
  self.name.output(logger)
  logger.write_string(", email: ")
  self.email.output(logger)
  logger.write_string(", avatar_url: ")
  self.avatar_url.output(logger)
  logger.write_string(", html_url: ")
  self.html_url.output(logger)
  logger.write_string("}")
}

///|
/// Get the authenticated user.
pub async fn get_authenticated(client : @client.GitHubClient) -> User {
  let json = client.get_json("/user")
  @json.from_json(json)
}

///|
/// Get a user by username.
pub async fn get(client : @client.GitHubClient, username : String) -> User {
  let json = client.get_json("/users/\{username}")
  @json.from_json(json)
}
