This project has code that can be copied into a [rake_cloudspin](https://github.com/cloudspinners/rake_cloudspin) component definition project to manage user accounts and roles for working with the component in AWS. This is bootstrap code that is applied to each AWS account where a given cloudspin component is deployed.

The main infrastructure elements defined in this project are a set of Core Cloudspin IAM Roles, and IAM users who can assume some subset of the roles.

NOTE: This code is not production ready. It is being used to experiment with how to implement the ideas here. So it is constantly changing, with no promise that it will remain consistent, coherent, or even working. It should be considered as an example, and something you might copy, modify, and use with caution.

The cloudspin tool should make it easy to set up IAM users, roles, and policies following [best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html). 

It includes Inspec tests to validate things about the roles and policies. These can be expanded to include controls based on your organisation's requirements.


## Core Cloudspin IAM Roles

Most cloudspin skeleton and template projects for AWS assume that a standard set of IAM Roles exist in an AWS account for each component that will be provisioned there. These roles will evolve, but the starter set right now is:

- spin_stack_manager-${component}
- spin_account_manager-${component}

These roles can be assumed by instance profiles - normally for change pipeline agents that manage infrastructure - and IAM users. Exactly which instances, and which users, are able to assume a role can vary for different AWS accounts. For instance, developers may have IAM user accounts for working with infrastructure in a sandbox account. But for accounts containing test and production instances of the component, only certain designated agent instances should be able to use these roles, except in an emergency.

NOTE: Enabling different instances and users to assume roles per account isn't implemented yet.


## Cloudspin IAM Users

Each human who needs to run cloudspin from their local workstation should have an IAM user defined in the `COMPONENT-ROOT/users.yaml` file. When the aws-roles stack is provisioned, the IAM user will be created in the AWS account. See the Usage section below for details.

Future implementations (or perhaps separate skeletons) should support [identity providers and federation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html) as an alternative to directly defined IAM users.


## Cloudspin account stacks

Each subfolder of the *account* folder in a cloudspin component project defines a stack that is to be applied to each AWS account where the cloudspin component is to be provisioned. No matter how many deployments are provisioned in an AWS account, there will be only one of each account stack applied to that AWS account.


# Usage: Setting up as a user

This is the process for each person who will use cloudspin for the component in the AWS account. Some steps are for the user themself (spin user), some are for an admin who will add the user's account (spin_account_manager).

## Prerequisites (spin user)

Each human user needs to have a PGP key. This will be used to encrypt a secret AWS access key for the user, so that only that person is able to get it, even if someone else is setting up their account for them.

Users will also need to have things installed on their local workstation in order to use their account, and cloudspin in general. (This should be documented somewhere else.)


## Configuring IAM Users in the stack (spin_account_manager)

Users are defined in the file `COMPONENT_ROOT/users.yaml`. This repository defines a set used for testing purposes, but you should replace these with your own.

The current syntax is simple, a list of usernames:

```yaml
api_users:
  - test-unprivileged-1
  - test-unprivileged-2
```

Note that if you have multiple cloudspin components in a given AWS accounts, the names of users must be unique across those components. So if you define user 'eddison_tollet' in two different components, you will get an error when you apply the second one, because the IAM user name will already exist. So either use different names for IAM users for each person in each component, or else implement federated identities.

The planned syntax for users should be more like:

```yaml
api_users:
  - eddison_tollet:
      public_pgp_key: "xxxxx"
      roles:
        - spin_stack_manager
  - lyanna_mormont:
      public_pgp_key: "xxxxx"
      roles:
        - spin_stack_manager
        - spin_account_manager
```

## Configure your local environment (spin user)

You need to install some basic tools (to be documented elsewhere).


### Generate your public PGP key string (spin user)

In order to have an AWS IAM user created for you to use cloudspin for the component, you need to provide your public PGP key.

For MacOS users, you can `brew install gpg`, and create a PGP key on your local keychain. Then, generate a string that can be used by cloudspin and Terraform with this command:

```bash
gpg --export YOUR_KEY_ID | base64
```

Give this string to the person who will run cloudspin to create your account. They will add you to the configuration, as described above, then run cloudspin, and then give you details for your local configuration, which are:

- AWS Access key ID
- AWS secret access key, encrypted with your PGP key
- Role ARN for each role you can assume


### Decrypt your secret access key (spin user)

On MacOS with GPG installed:

```bash
export GPG_TTY=$(tty)
echo ENCRYPTED_STRING | base64 --decode | gpg -d
```

Use this key in the step below.


### Add your IAM user to your local AWS configuration (spin user)

Edit your `~/.aws/credentials` file, and add your new AWS access key dteails to a new profile:

```ini
[edd_cloudspin]
aws_access_key_id = AKIA........
aws_secret_access_key = xxxxxxxxxxx
```

The name of the profile doesn't matter, but you'll need to use it in the next step.


### Configure cloudspin to use your new credentials profile (spin user)

Create or edit your `component-local.yaml` file, and change the `aws_profile` configuration value:

```yaml
aws_profile: edd_cloudspin
```

### Add the roles to assume to your local AWS configuration (spin user)

Create or edit your local AWS configuration file `~/.aws/config` to add the roles that cloudspin will assume when managing infrastructure. These should be AWS profiles named according to the convention: "`*assume*_${IAM_ROLE}_${COMPONENT}`". Following this naming convention is needed to make sure that cloudspin works correctly (particularly for running inspec tests).

So a template for the profile in `~/.aws/config` is:

```ini
[profile assume-IAM_ROLE-YOUR_COMPONENT]
role_arn = arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/IAM_ROLE-YOUR_COMPONENT
source_profile = IAM_USER_PROFILE_FROM_YOUR_CREDENTIALS_FILE
```

For example:

```ini
[profile assume-spin_stack_manager-skeleton]
role_arn = arn:aws:iam::000000000000:role/spin_stack_manager-skeleton
source_profile = edd_cloudspin
```

The *role_arn* value will have been printed in the output from the `./go account:aws-roles:provision` command.


# Usage: Managing the aws-roles stack (spin_account_manager)

Assuming that Bootstrapping has been done on the AWS account, as documented below, and that you have configured your local environment, as documented above, then you can run cloudspin for the component in the AWS account. If you are assigned to the `spin_account_manager` role, then you can make changes to the account/aws-roles stack code and apply them. These are the commands for doing this:


```bash
./go account:aws-roles:plan
# Evaluate the output before proceeding, then:
./go account:aws-roles:provision
# Evaluate the output before proceeding, then:
./go account:aws-roles:test
```

# Bootstrapping

The aws-roles stack has a bootstrapping issue. You need the spin_account_manager IAM role, and an IAM user who can assume that role, in order to apply the aws-roles stack. But you need to apply the aws-roles stack in order to create the spin_account_manager role and user.

The way around this is to manually create a bootstrap IAM user with an access key, and sufficient privileges to apply the aws-roles stack the first time. Once you've applied the stack, assuming you included an IAM user for yourself, you can then use that user to update the stack in the future. You can then remove the bootstrap user, so that all users (other than your root user) are managed through code.

WARNING: Don't use your root user to apply aws-roles! You should not have AWS access keys on your root user. Use the root user to create your bootstrap account from the AWS console, and you should not need to use the root user after that except in a pinch.


## Add a managed IAM user for yourself to the component configuration

In the file `users.yaml` in the root of this repository, add an entry to the `api_users` section for yourself, and also add yourself to the stack-managers and administrators group:

```yaml
api_users:
  - eddison_tollet:
      public_pgp_key: "xxxxx"
      roles:
        - spin_stack_manager
```

## Create a bootstrap IAM user

Create a user (for example, **bootstrap_cloudspin**) and add it to the Power Users managed group, and attach the IAMFullAccess policy to the user. (TODO: we can probably limit this much further, may not need much more than a subset of IAM permissions). (TODO: consider creating a role and assume-role for this? It's better practice, but a bit complicated for a disposable one-off). Generate an API access key for the user. The user should not need a console password.


## Add the bootstrap access key to your credentials file

Put the access credentials for the bootstrap user into your [AWS credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html). Give it a profile name, such as `bootstrap_cloudspin`.

File: `~/.aws/credentials`:
```ini
[bootstrap_cloudspin]
aws_access_key_id = AKIA........
aws_secret_access_key = xxxxxxxxxxx
```

## Bootstrapping the aws-account stack

Once you have this all in place, you can plan and provision the stack. Do this by applying the stack, setting environment variables to use the bootstrap credentials.

```bash
AWS_PROFILE=bootstrap_cloudspin ADMIN_ROLE_ARN= ./go account:aws-roles:plan
# Evaluate the output before proceeding
AWS_PROFILE=bootstrap_cloudspin ADMIN_ROLE_ARN= ./go account:aws-roles:provision
```

## Run the tests

```bash
./go account:aws-roles:test
```

This runs some checks on the user accounts configured in the project, to make sure they have the expected settings. The tests under `account/aws-roles/tests/inspec` may be a useful starting point for validating policies you want for your IAM users and policies.

These tests also ensure that your own local AWS credentials are working correctly; that they can assume the administrator role, and that they do not have more permissions than necessary. If you left your bootstrap credentials in the configuration, a test should fail.

## Clean up

It's recommended to remove the IAM user you used for bootstrapping (e.g. bootstrap_cloudspin), so that all of your IAM users are managed as code. In the event that something goes wrong with the managed accounts, you'd need to use your root credentials to log in and fix things.


## Tearing it down

If you want to remove the IAM roles and users defined by this stack, you'll need to follow the bootstrap steps as above, including having a manually created bootstrap user, add their credentials to your aws credentials file, and then run the destroy target:

```bash
AWS_PROFILE=bootstrap_cloudspin ADMIN_ROLE_ARN= ./go account:aws-roles:destroy
```
