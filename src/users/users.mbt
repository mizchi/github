///| Authenticated user or public user profile.
pub struct User {
  id : Int
  login : String
  name : String?
  email : String?
  avatar_url : String
  html_url : String
} derive(Show, Eq, FromJson, ToJson)

///| Get the authenticated user.
pub async fn get_authenticated(client : @client.GitHubClient) -> User {
  let json = client.get_json("/user")
  @json.from_json(json)
}

///| Get a user by username.
pub async fn get(client : @client.GitHubClient, username : String) -> User {
  let json = client.get_json("/users/\{username}")
  @json.from_json(json)
}
