provider "github" {
  token = var.github_token
  owner = "SPR0STO"
}

resource "github_repository" "ci-templates" {
  name                   = "ci-templates"
  visibility             = "public"
  auto_init              = true
  delete_branch_on_merge = true
}

locals {
  protected_branches = ["main", "acceptance", "production"]
}

resource "github_branch" "predefined_branches" {
  for_each   = toset(local.protected_branches)
  repository = github_repository.ci-templates.id
  branch     = each.value
}

resource "github_branch_protection" "protected_branches" {
  for_each       = toset(local.protected_branches)
  repository_id  = github_repository.ci-templates.id
  pattern        = each.value
  enforce_admins = true

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  required_status_checks {
    strict   = true
    contexts = ["ci/linters"]
  }

}
