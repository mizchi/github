///|
async fn main {
  let token = @env.get_env_var("GITHUB_TOKEN").unwrap_or("")
  let client = @client.GitHubClient::new(token)
  defer client.close()

  println("=== Repository ===")
  try {
    let repo = @repos.get(client, "mizchi", "flaker")
    println("Name: \{repo.full_name}, branch: \{repo.default_branch}")
  } catch {
    e => println("Error: \{e}")
  }

  println("\n=== Issues ===")
  try {
    let issues = @issues.list(client, "mizchi", "flaker", per_page=3)
    for issue in issues {
      println("  #\{issue.number}: \{issue.title}")
    }
  } catch {
    e => println("Error: \{e}")
  }

  println("\n=== Workflow Runs ===")
  try {
    let runs = @actions.list_workflow_runs(client, "mizchi", "flaker", per_page=3)
    for run in runs.workflow_runs {
      println("  [\{run.conclusion}] \{run.head_sha.substring(end=7)}")
    }
  } catch {
    e => println("Error: \{e}")
  }

  println("\n=== Search Issues ===")
  try {
    let results = @search.issues(client, "repo:mizchi/flaker is:open")
    println("Found: \{results.total_count}")
  } catch {
    e => println("Error: \{e}")
  }

  println("\n=== Check Runs (main) ===")
  try {
    let checks = @checks.list_for_ref(client, "mizchi", "flaker", "main", per_page=5)
    for cr in checks.check_runs {
      let conclusion = cr.conclusion.unwrap_or("pending")
      println("  [\{conclusion}] \{cr.name}")
    }
  } catch {
    e => println("Error: \{e}")
  }

  println("\n=== Compare (HEAD~3...HEAD) ===")
  try {
    let cmp = @repos.compare(client, "mizchi", "flaker", "HEAD~3", "HEAD")
    println("Status: \{cmp.status}, commits: \{cmp.total_commits}, files: \{cmp.files.length()}")
  } catch {
    e => println("Error: \{e}")
  }

  println("\n=== Pagination (branches, all pages) ===")
  try {
    let all = client.get_all_pages(
      "/repos/mizchi/flaker/branches?per_page=3",
      fn(json) {
        match json.as_array() {
          Some(arr) => arr
          None => []
        }
      },
      max_pages=5,
    )
    println("Total branches via pagination: \{all.length()}")
  } catch {
    e => println("Error: \{e}")
  }

  println("\nDone!")
}
