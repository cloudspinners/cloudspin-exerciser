
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

## About account stacks

Each subfolder of the *account* folder in a cloudspin component project defines a stack that is to be applied to each AWS account where the cloudspin component is to be provisioned. No matter how many deployments are provisioned in an AWS account, there will be only one of each account stack applied to that AWS account.


## The aws-roles stack

The **accounts/aws-roles** stack defines core roles and policies that will be used for managing the cloudspin component stacks in AWS. It also defines IAM users, that you and your teammates will use to run cloudspin. These IAM users are assigned permission to assume relevant core roles.


## The cloudspin roles

- stack-manager: Create, update and destroy stacks
- administrator: Update the aws-roles stack itself. May be used for other stacks that require higher privileges (IAM).


## Bootstrapping

The aws-roles stack has a bootstrapping issue. You need the administrator IAM role, and an IAM user who can assume that role, in order to apply the aws-roles stack. But you need to apply the aws-roles stack in order to create the administrator role and user.

The way around this is to manually create a bootstrap IAM user with an access key, and sufficient privileges to apply the aws-roles stack the first time. Once you've applied the stack, assuming you included an IAM user for yourself, you can then use that user to run the stack in the future. You can then remove the bootstrap user, so that all users (other than your root user) are managed through code.

WARNING: Don't use your root user to apply aws-roles! You should not have AWS access keys on your root user. Use the root user to create your bootstrap account, and you should not need to use the root user after that except in a pinch.


### Add a managed IAM user for yourself to the component configuration

In the file `users.yaml` in the root of this repository, add an entry to the `api_users` section for yourself, and also add yourself to the stack-managers and administrators group:

```yaml
api_users:
  - kief-cloudspin:
      pgp_public_key: xxxxxxx

roles:
  - stack-manager:
      users:
        - kief-cloudspin
  - administrator:
      users:
        - kief-cloudspin
```


#### How do I generate my PGP key string?

Assuming you have a PGP key, and use the gpg client, then you can output your public key in a suitable format with this command:

```bash
gpg --export YOUR_KEY_ID | base64
```


### Create the bootstrap user

Create a user and add it to the Power Users managed group, and attach the IAMFullAccess policy to the user. (TODO: we can probably limit this much further, may not need much more than a subset of IAM permissions). (TODO: consider creating a role and assume-role for this? It's better practice, but a bit complicated for a disposable one-off).


### Add the bootstrap access key to your credentials file

Put the access credentials for the bootstrap user into your [AWS credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html). Give it a profile name, such as `bootstrap_cloudspin`.

```ini
[bootstrap_cloudspin]
aws_access_key_id = AKIA........
aws_secret_access_key = xxxxxxxxxxx
```


### Bootstrapping the aws-account stack

Once you have this all in place, you can plan and provision the stack. Do this by applying the stack, setting environment variables to use the bootstrap credentials.

```bash
AWS_PROFILE=bootstrap_cloudspin ADMIN_ROLE_ARN= ./go account:aws-roles:plan
# Evaluate the output before proceeding
AWS_PROFILE=bootstrap_cloudspin ADMIN_ROLE_ARN= ./go account:aws-roles:provision
```

### Retrieve the credentials for your new IAM user for API access

The output of the provision command should print, for each IAM user, the access key id, and an encrypted string containing the secret access key. This will be encrypted with the PGP key set for that particular user in the `users.yaml` file, as described above.

Best practice is for each user to have their own PGP key, so that only they are able to decrypt the secret key. Even the person applying the aws-account stack should not have any way to discover a user's secret key.

To decrypt your secret access key:

```bash
export GPG_TTY=$(tty)
echo ENCRYPTED_STRING | base64 --decode | gpg -d
```

### Add your IAM user to your local AWS configuration

Now that you have bootstrapped an IAM User for yourself, you can add it to your local AWS configuration so you can manage stacks for this component.

Go back to your `~/.aws/credentials` file, and add your new IAM user credentials to a new profile:

```ini
[kief-cloudspin]
aws_access_key_id = AKIA........
aws_secret_access_key = xxxxxxxxxxx
```

Then, edit your `component-local.yaml` file, and change the `aws_profile` configuration value:

```yaml
aws_profile: kief-cloudspin
```

Finally, create or edit your local AWS configuration file `~/.aws/config` to add the roles that cloudspin will assume when managing infrastructure:

```ini
[profile assume_role_for_account_aws-roles]
role_arn = arn:aws:iam::000000000000:role/stack_manager-exerciser
source_profile = kief-cloudspin
```

The *role_arn* value will have been included in the output from the `./go account:aws-roles:provision` command.


### Run the tests

```bash
./go account:aws-roles:test
```

This runs some checks on the user accounts configured in the project, to make sure they have the expected settings. The tests under `account/aws-roles/tests/inspec` may be a useful starting point for validating policies you want for your IAM users and policies.

These tests also ensure that your own local AWS credentials are working correctly; that they can assume the administrator role, and that they do not have more permissions than necessary. If you left your bootstrap credentials in the configuration, a test should fail.


### Applying changes to aws-account (after bootstrap)


```bash
./go account:aws-roles:plan
# Evaluate the output before proceeding
./go account:aws-roles:provision
# Evaluate the output before proceeding
./go account:aws-roles:test
```
