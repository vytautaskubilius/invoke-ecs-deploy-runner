#!/bin/bash
#
# Script used by GitHub Actions to trigger deployments via the infrastructure-deployer CLI utility.
#
# Required positional arguments:
# - COMMAND : The command to run. Should be one of plan, plan-all, apply, apply-all, docker-image-build.

set -euo pipefail

# Function that invokes the ECS Deploy Runner using the infrastructure-deployer CLI. This will also make sure to assume
# the correct IAM role.
function invoke_infrastructure_deployer {
  local -r command="$1"

  local assume_role_exports
  assume_role_exports="$(aws-auth --role-arn "arn:aws:iam::$aws_account_id:role/allow-ecs-deploy-runner-invoker-access" --role-duration-seconds 3600)"

  local container
  if [[ "$command" == "plan" ]] || [[ "$command" == "plan-all" ]]; then
    container="terraform-planner"
  elif [[ "$command" == "apply" ]] || [[ "$command" == "apply-all" ]]; then
    container="terraform-applier"
  elif [[ "$command" == "docker-image-build" ]]; then
    container="docker-image-builder"
  fi

  if [[ "$container" == "terraform-planner" ]] || [[ "$container" == "terraform-applier" ]]; then
  (eval "$assume_role_exports" && \
    infrastructure-deployer --aws-region "$ECS_DEPLOY_RUNNER_REGION" -- "$container" infrastructure-deploy-script --repo git@github.com:"$GITHUB_REPOSITORY" --ref "$GITHUB_REF" --binary "terragrunt" --command "$command" --deploy-path "$CONTEXT")
  elif [[ "$container" == "docker-image-builder" ]]; then
  (eval "$assume_role_exports" && \
    infrastructure-deployer --aws-region "$ECS_DEPLOY_RUNNER_REGION" -- "$container" build-docker-image --repo https://github.com/"$GITHUB_REPOSITORY" --ref "$GITHUB_REF" --context-path "$CONTEXT" --docker-image-tag "$AWS_ACCOUNT_ID.dkr.ecr.$ECR_REPO_REGION.amazonaws.com/$CONTEXT:$VERSION" $BUILD_ARGS)
  fi

}

invoke_infrastructure_deployer "$@"
