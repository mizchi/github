///|
async fn main {
  let token = @env.get_env_var("GITHUB_TOKEN").unwrap_or("")
  let client = @client.GitHubClient::new(token)
  defer client.close()

  // 1. Public API: get repo (no auth needed)
  println("=== Repository (public) ===")
  try {
    let repo = @repos.get(client, "mizchi", "flaker")
    println("Name: \{repo.full_name}")
    println("Default branch: \{repo.default_branch}")
  } catch {
    e => println("Error: \{e}")
  }

  // 2. Public API: list branches
  println("\n=== Branches ===")
  try {
    let branches = @repos.list_branches(client, "mizchi", "flaker")
    for b in branches {
      println("  - \{b.name}")
    }
  } catch {
    e => println("Error: \{e}")
  }

  // 3. Public API: list issues
  println("\n=== Issues (open) ===")
  try {
    let issues = @issues.list(client, "mizchi", "flaker", per_page=3)
    for issue in issues {
      println("  #\{issue.number}: \{issue.title}")
    }
  } catch {
    e => println("Error: \{e}")
  }

  // 4. Authenticated: get user
  if token != "" {
    println("\n=== Authenticated User ===")
    try {
      let me = @users.get_authenticated(client)
      println("Login: \{me.login}")
    } catch {
      e => println("Error: \{e}")
    }
  }

  // 5. Public API: workflow runs
  println("\n=== Recent Workflow Runs ===")
  try {
    let runs = @actions.list_workflow_runs(client, "mizchi", "flaker", per_page=3)
    for run in runs.workflow_runs {
      println("  [\{run.conclusion}] \{run.head_sha.substring(end=7)} \{run.event}")
    }
  } catch {
    e => println("Error: \{e}")
  }

  println("\nDone!")
}
