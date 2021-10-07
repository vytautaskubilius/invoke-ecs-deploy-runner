# GitHub Action for invoking the ECS deploy runner

This repository contains a GitHub action that allows the user to easily invoke the Gruntwork ECS deploy runner from any
repository that requires it. This is heavily based on
[*How to configure a production-grade CI-CD workflow for infrastructure code*](https://gruntwork.io/guides/automations/how-to-configure-a-production-grade-ci-cd-setup-for-apps-and-infrastructure-code/).

# Table of Contents

- [Usage](#usage)
- [Examples](#examples)
- [Links](#links)
- [To Do](#to-do)

## Usage

### Setup

- The following environment variables must be set:
  - `AWS_ACCOUNT_ID` - the AWS account ID where the ECS deploy runner is deployed
    - Make sure this is enclosed in double quotes as otherwise leading zeros will be trimmed.
  - `ECS_DEPLOY_RUNNER_REGION` - region where the ECS deploy runner is deployed.
  - `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` - AWS credentials for the machine user that invokes the ECS deploy
    runner.
  - `GITHUB_OAUTH_TOKEN` - GitHub personal auth token that can be used to reach Gruntworks repositories.
- A mandatory input variable `command` that currently accepts the following values to execute these commands via the
  ECS deploy runner:
  - `plan` and `plan-all` (Terragrunt)
  - `apply` and `apply-all` (Terragrunt)
  - `docker-image-build` (Docker)
- A mandatory input variable `context` must be set to the path in which the `command` will be executed.

The action also accepts the following optional inputs:

- Versions of the following Gruntwork tools and modules (defaults can be viewed in `action.yaml`):
  - `gruntwork-installer-version`
  - `terraform-aws-ci-version`
  - `terraform-aws-security-version`
- The name of the main branch of the repository can be set via the following option (defaults to `main`):
  - `main-branch-name`
- The following options apply when using the `docker-image-build` command:
  - a `build_args` input variable can be used to populate the Docker build time arguments. The variable must be 
    populated similar to how it would work when using the `docker build` command, with each separate argument being 
    prepended with `--build-arg` - e.g. `build_args: --build-arg ARG1 --build-arg ARG2`.
  - The `ECR_REPO_REGION` environment variable must be set to determine the AWS region where the ECR repository is hosted.

### Components

The action does the following:

1. It installs Gruntworks tools via a helper script. A Gruntworks subscription is required for this.
2. It uses the Gruntworks `infrastructure-deployer` CLI to invoke either the `infrastructure-deploy-script` or 
   `build-docker-image` scripts on the `terraform-planner`, `terraform-applier`, or the `docker-image-builder`
   containers (depending on the `command` input) that are provided by default with the ECS Deploy Runner.  

## Examples

Below is an example of a workflow that executes `terragrunt plan-all` on a push to any branch, and 
executes a `terragrunt apply-all` on pushes to `main`. It utilizes [GitHub Environments](https://docs.github.com/en/actions/reference/environments)
that can be used to more granularly set environment variables, and set up environment protection rules.

```yaml
on:
  push:
    branches:
      - "**"

env:
  AWS_ACCOUNT_ID: 123456789012
  AWS_REGION: "us-east-1"  # Region where the ECS deploy runner is hosted.
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  GITHUB_OAUTH_TOKEN: ${{ secrets.PAT }}  # Personal Access Token that allows access to Gruntworks private repositories

jobs:
  plan:
    runs-on: ubuntu-latest

    steps:
      - name: Check out the repo
        uses: actions/checkout@v2

      - name: Terragrunt plan-all
        uses: vytautaskubilius/invoke-ecs-deploy-runner@v0.1.0
        with:
          command: plan-all
          context: path/to/terragrunt/config

  apply:
    needs:
      - plan
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Check out the code
        uses: actions/checkout@v2

      - name: Terragrunt plan-all
        uses: vytautaskubilius/invoke-ecs-deploy-runner@v0.1.0
        with:
          command: apply-all
          context: path/to/terragrunt/config
```

## Links

- [How to configure a production-grade CI-CD workflow for infrastructure code](https://gruntwork.io/guides/automations/how-to-configure-a-production-grade-ci-cd-setup-for-apps-and-infrastructure-code/)

## To Do

- Add `ami-builder` support.
