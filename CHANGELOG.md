# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3] - 2021-10-07

### Changed

- Use the commit hash for Terraform actions instead of the git ref as the `infrastructure-deploy-script` can't parse
  the ref with the `refs/heads` prefix.

## [0.1.2] - 2021-10-07

### Changed

- Append `.git` to the GitHub repo parameter to match the expected format of the ECS Deploy Runner allowlist.

## [0.1.1] - 2021-10-07

### Changed

- Fixed a mistyped variable.

## [0.1.0] - 2021-10-07

### Added

- GitHub Action that allows the user to invoke the ECS Deploy Runner with `terraform-planner`, `terraform-applier`, and
  `docker-image-builder` container tools.

[0.1.3]: https://github.com/vytautaskubilius/invoke-ecs-deploy-runner/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/vytautaskubilius/invoke-ecs-deploy-runner/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/vytautaskubilius/invoke-ecs-deploy-runner/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/vytautaskubilius/invoke-ecs-deploy-runner/releases/tag/v0.1.0
