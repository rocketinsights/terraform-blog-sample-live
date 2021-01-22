# terraform-blog-sample-live

This live repo extends modules that are managed in [terraform-blog-sample-module](https://github.com/rocketinsights/terraform-blog-sample-module).

## Overview

This repo extends the terraform [terraform-blog-sample-module](https://github.com/rocketinsights/terraform-blog-sample-module) repo and creates:
```
VPC
Load Balancer
Security Groups
EC2 instance
Installs/starts nginx on the EC2 instance (via a provisioner)
```

### Directory Structure

There is a named directory for each environment (dev, staging and prod) each of which contain its own `terragrunt.hcl` configuration file.

All environments extend the same [terraform-blog-sample-module](https://github.com/rocketinsights/terraform-blog-sample-module) repo. The terragrunt.hcl config file in each env directory provides two main functions:

1. Pin the version of [terraform-blog-sample-module](https://github.com/rocketinsights/terraform-blog-sample-module) repo to use in the given environment
1. Set/override inputs in the given environment.

Inputs correspond to module variables. For example, we use inputs in the staging and prod environment `terragrunt.hcl` files to configure larger EC2 cluster instances. Any variable that's defined in the root level `variables.tf` file in [terraform-blog-sample-module](https://github.com/rocketinsights/terraform-blog-sample-module) can be set or overridden as an env specific input.


### Deploying Changes

Typically, you want to apply changes to one environment at a time moving from dev to staging to prod.

There are two scenarios for applying changes: changes that require new infrastructure or updates to inputs.

##### Changes that require new infrastructure:

1. Create a pull request with the required changes for [terraform-blog-sample-module](https://github.com/rocketinsights/terraform-blog-sample-module) and merge to `master`. (Merging to master against the terraform-blog-sample-module repo will increment the module version number)
1. Create a pull request that increments the module version number in the `terragrunt.hcl` of the environment you'd like to update.
1. REVIEW THE PLAN OUTPUT IN THE PR! - This is a critical step as you want to ensure that only the changes you intend to apply are listed in the plan output.
1. Merge the PR to `master`.

Once the PR has been merged to `master`, the Github Workflow will apply the changes that we're listed in the PR plan. (This is why it's critical to review the plan output of a PR)


##### Updates to inputs:

No module version changes are needed if you are only updating inputs.

1. Create a pull request that updates the inputs in the `terragrunt.hcl` of the environment you'd like to update.
1. REVIEW THE PLAN OUTPUT IN THE PR! - This is a critical step as you want to ensure that only the changes you intend to apply are listed in the plan output.
1. Merge the PR to `master`.

Once the PR has been merged to `master`, the Github Workflow will apply the changes that we're listed in the PR plan. (This is why it's critical to review the plan output of a PR)


### Changing multiple environments at once

WARNING: If you change multiple environment `terragrunt.hcl` files in a single PR, those changes will be applied to all envs changed in the PR when merged to `master`.

This can be useful in rare instances but it is HIGHLY RECOMMENDED THAT PRs CONTAIN CHANGES TO ONLY A SINGLE ENVIRONMENT AT A TIME.

Please use caution!!!


## CI/CD with Github Workflows
This repo uses Github Workflows to output what changes would be applied to the infrastructure. 

WARNING: Infrastructure changes are automatically applied when you merge to master.

#### Pull Requests
Each pull request executes a `terragrunt plan-all` and will output the changes that it would apply if you executed an `apply-all`.

#### Merges to Master
Executes a `terragrunt plan-all` followed by `terragrunt apply-all`.

#### AWS Credentials (NOT ACTIVE FOR THIS EXAMPLE BLOG REPO)
An IAM User is manually provisioned in each of the environment specific AWS accounts to be used with this repo. The programmatic creds are set as secrets in the repo config and are accessed by the Github Workflow in order to read infrastructure state from S3 and provide the plan output.

#### Github Deploy Key (NOT ACTIVE FOR THIS EXAMPLE BLOG REPO)
In order for this repo to reference the infrastructure-modules repo in a Github Workflow, we leverage an ssh deploy key. The private end of the deploy key pair is set as a repo secret and is used to clone the infrastructure-modules repo in a Github workflow step.

More about repo deploy keys can be found [here](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys).


### Applying changes locally

It's possible (but not recommended) to apply infrastructure changes from a local environment using the same commands that the Github Workflow executes.

1. Install Terraform and Terragrunt with [tfenv](https://github.com/tfutils/tfenv) and [tgenv](https://github.com/rocketinsights/tgenv)

    ```
    $ brew tap rocketinsights/tgenv
    $ brew install tgenv tfenv
    $ tgenv install
    $ tfenv install
    ```

    The versions of Terraform and Terraform used are pinned by the `.terraform-version` and `.terragrunt-version` files. Each site directory can leverage different versions and can be upgraded strategically.

1. Set AWS credentials locally as environment variables


## Terragrunt command basics

### Running targeted environment specific commands with Terragrunt

For example, if you just wanted to make changes to the `dev` env, you would:

    $ cd dev/
    $ terragrunt plan-all
    $ terragrunt apply-all

This would apply changes to only the `dev` environment.
