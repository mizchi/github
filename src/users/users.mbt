///|
/// Authenticated user or public user profile.
pub struct User {
  id : Double
  login : String
  name : String?
  email : String?
  avatar_url : String
  html_url : String
} derive(Debug, Eq, FromJson, ToJson)

///|
pub impl Show for User with fn output(self, logger) {
  logger.write_string("{id: ")
  logger.write_string(@debug.to_string(self.id))
  logger.write_string(", login: ")
  logger.write_string(@debug.to_string(self.login))
  logger.write_string(", name: ")
  logger.write_string(@debug.to_string(self.name))
  logger.write_string(", email: ")
  logger.write_string(@debug.to_string(self.email))
  logger.write_string(", avatar_url: ")
  logger.write_string(@debug.to_string(self.avatar_url))
  logger.write_string(", html_url: ")
  logger.write_string(@debug.to_string(self.html_url))
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
