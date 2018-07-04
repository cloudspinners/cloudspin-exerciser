
This project is used to test the [rake_cloudspin](https://github.com/cloudspinners/rake_cloudspin) tooling for building infrastructure projects. Unlike some of the other [cloudspin](https://github.com/cloudspinners) repositories, this doesn't intend to illustrate design patterns or concepts. It may be useful as a pared down example of a cloudspin project structure and elements. But its primary purpose is to enable testing that the stuff works as it should.

So the actual infrastructure code, with some exceptions, are kept minimal in order to optimize for speed and cost of running tests.


# What should be tested

- IAM users, roles, policies, etc. are defined and used correctly with the toolset
- Stacks are configured and tested properly
- Multiple deployments are configured properly
- Integration between stacks works correctly
- Pipelines work correctly


# IAM

The cloudspin tool should make it easy to set up IAM users, roles, and policies following [best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html). 

Some things this part should do:

- How do we define IAM users so that developers can work on sandbox projects?
- What roles should be set up for managing cloudspin infrastructure?
- How do we validate that baseline policies are in place?


## The aws-roles stack

The **accounts/aws-roles** stack defines a few core roles and policies. It is also used to create a set of IAM users, and assign them permission to assume the core roles, so they can be tested. These are also used by other parts of this project - the users and roles here are used to carry out actions on other stacks.


## Enabling bootstrapping

The aws-roles stack has a bootstrapping issue. It creates the IAM users and roles that are needed to provision stacks. But how is the aws-roles stack itself provisioned?

The answer is to set up an IAM user with rights to administer IAM, add an access key, and put it into your [AWS credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html). Then, configure cloudspin to use this for bootstrapping the aws-roles stack. Create a file `component-local.yaml` in the base of this repository, and add a `aws_profile_for_bootstrap` configuration value:

```yaml
aws_profile_for_bootstrap: MYPROFILE
```

## Applying and testing the account configuration

The *account* folder in any component contains stacks that are to be applied to each AWS account where the cloudspin component is to be provisioned. No matter how many deployments are provisioned in an AWS account, there will be only one of each account stack applied to that AWS account. However, each AWS account must have the stacks applied.

Each folder under `./accounts` is a separate stack to be applied.

For this project, the routine to bootstrap and test is:

```bash
./go account:aws-roles:plan
# Evaluate the output before proceeding
./go account:aws-roles:provision
# Evaluate the output before proceeding
./go account:aws-roles:test
```

