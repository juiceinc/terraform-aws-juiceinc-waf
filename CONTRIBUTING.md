# Contribution Guide

## Introduction
Hello! And thanks for wanting to help contribute to the Terraform WAF module.

## Getting Started
### Development Process / Ground Rules
Be respectful of the code that has come before you and the code that you will leave behind for others.

### Setting up a development environment
As the first step to being able to use this module, make sure you're setup on your local machine with the following:
- Required: Terraform, we are currently using v0.10.8.
- Make sure you have AWS credentials setup correctly.
- Optional: We find the [terraform-landscape](https://github.com/coinbase/terraform-landscape) tool useful in finding policy differences while developing.

cd into examples/basic:
- terraform init
- terraform plan
- terraform apply

Note, the example uses dummy values, the main thing you'll need to provide is the ARN of your target application load balancer.

## Pull Requests
All changes to this repository are done via [Pull Requests](https://help.github.com/articles/about-pull-requests/) in Github. Make sure to include a clear description of your changes in the PR.

## Releases
Releases will be made by repository administrators.