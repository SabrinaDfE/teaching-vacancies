# Teaching Vacancies

* [API Documentation](https://docs.teaching-vacancies.service.gov.uk)
* [API Keys](/documentation/api-keys.md)
* [Authentication](/documentation/authentication.md)
* [Continuous delivery](/documentation/continuous-delivery.md)
* [Hosting](/documentation/hosting.md)
* [Logging](/documentation/logging.md)
* [Onboarding](/documentation/onboarding.md)
* [Misc](#misc)
* [Search](/documentation/search.md)
* [Troubleshooting](#troubleshooting)

## Setup

Welcome! :tada: :fireworks:

By now you should be [onboarded](/documentation/onboarding.md).

The first thing to do is to install the required development tools. If you are on a Mac, this [script](https://github.com/thoughtbot/laptop) will install Homebrew, Git, asdf-vm, Ruby, Bundler, Node.js, npm, Yarn, Postgres, Redis and other useful utilities.

Then, clone the project with SSH:

```bash
git clone git@github.com:DFE-Digital/teaching-vacancies.git
```

If you are on a new device, remember to [generate a new SSH key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

### Dependencies

* [Ruby](https://www.ruby-lang.org)
* [NodeJS](https://nodejs.org)

A tool like [asdf-vm](https://asdf-vm.com) can help you install the required versions of Ruby and Node.js.
Current versions that match production ones are specified in [.tool-versions](/.tool-versions).

If asdf-vm is installed correctly, from the project repository you can just execute:

```bash
asdf install
```

### Services

Make sure you have the following services configured and running on your development background:

* [PostgreSQL](https://www.postgresql.org)
* [Redis](https://redis.io)


### ChromeDriver

```bash
brew tap homebrew/cask
brew cask install chromedriver
```

### AWS credentials, MFA, and role profiles

When onboarded, you will be provided with an AWS user. You can use it to access the AWS console at:
[https://teaching-vacancies.signin.aws.amazon.com/console](https://teaching-vacancies.signin.aws.amazon.com/console).

- Log in to the console and go to [My Security Credentials](https://console.aws.amazon.com/iam/home?region=eu-west-2#/security_credentials).
- Choose `Assign MFA device` and set up an authenticator app as a Virtual MFA device.
- If using an Authenticator App, scan the QR code, and when prompted to enter codes, enter the first code, wait 30 seconds until a new code has been generated on your authenticator app, and enter the new code in the second box.
- Log out, and back in. You should be prompted for an MFA code.
- Go to [My Security Credentials](https://console.aws.amazon.com/iam/home?region=eu-west-2#/security_credentials).
- Choose `Create access key`. Note the credentials securely, as you will need these to configure the AWS CLI.

### Assuming a role in the console

- First check that your user account does not have permissions - go to the [Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table)
- Assume the [ReadOnly](https://signin.aws.amazon.com/switchrole?account=530003481352&roleName=ReadOnly&displayName=TV%20ReadOnly) role
- You should now be able to see secrets in the [Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table)
- Edit a secret. When you click the button `Save changes`, you should see an error like
`User: arn:aws:sts::530003481352:assumed-role/ReadOnly/YOURUSERNAME is not authorized to perform: ssm:PutParameter on resource: arn:aws:ssm:eu-west-2:530003481352:parameter/teaching-vacancies/dev/infra/secrets`
- If you need to edit a secret, assume the [SecretEditor](https://signin.aws.amazon.com/switchrole?account=530003481352&roleName=SecretEditor&displayName=TV%20SecretEditor) role. 

Install and configure the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

```bash
brew install awscli
```

[Configure the CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) by running

```bash
aws configure
```

You'll be prompted to enter:
- AWS Access Key ID 
- AWS Secret Access Key
- Default region name (choose `eu-west-2`)
- Default output format (choose `json`)

To check that everything has been done correctly, check the contents of the generated files

```bash
cat ~/.aws/credentials
```

It should contain a default entry, with your access key and secret key:

```
[default]
aws_access_key_id=<AWS_ACCESS_KEY_ID>
aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>
```

Edit `~/.aws/config`

It should begin with the region and output defaults:

```
[default]
region = eu-west-2
output = json
```

Add two profiles to this, replacing `<YOURUSERNAME>`

```
[profile readonly]
role_arn = arn:aws:iam::530003481352:role/readonly
source_profile = default
mfa_serial = arn:aws:iam::530003481352:mfa/<YOURUSERNAME>

[profile secreteditor]
role_arn = arn:aws:iam::530003481352:role/secreteditor
source_profile = default
mfa_serial = arn:aws:iam::530003481352:mfa/<YOURUSERNAME>
```

When using the AWS CLI, you may pass in the profile like so

```bash
aws --profile readonly s3 ls
```

### Environment Variables

Some environment variables are stored in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table), some are stored in the repository.

Secrets (eg: API keys) are stored in AWS Systems Manager Parameter Store in `/teaching-vacancies/<env>/app/*` and `/teaching-vacancies/<env>/infra/*` files.

Non-secrets (eg: public URLs or feature flags) are stored in the repository in `terraform/workspace-variables/<env>_app_env.yml` files.

Open your Authenticator App, and get the 6-digit MFA code.

Run the following command to fetch all the required environment variables for development and output to a shell environment file:

```
make -s local print-env mfa_code=123456 > .env
```

To run the command above you need [AWS credentials](#aws-credentials).

[Git secrets](/documentation/secrets-detection.md) offers an easy way to defend against accidentally publishing these secrets.

### Install dependencies

Install Ruby dependency libraries:

```bash
bundle
```

Install Javascript dependency libraries:

```bash
yarn
```

### Setup the database

```bash
bundle exec rails db:create db:schema:load
```

If you have problems connecting with the database, edit `DATABASE_URL` variable in `.env`

### Seeding the database

To create a few vacancies in your database run:

```bash
bundle exec rails db:seed
```

### Importing data

#### GIAS data (schools, trusts and local authorities)

Populate your environment with real school data. This is taken from
[GIAS](https://get-information-schools.service.gov.uk/). It might take a while, so make a cup of tea while you wait.

```bash
bundle exec rails gias:import_schools
```

#### ONS Location polygons

Run these rake tasks to populate your database with location polygons (which are used in some cases to search by location).

```bash
bundle exec rails ons:import_location_polygons
```

### Run the server

```bash
bundle exec rails server
```

Look at that, you’re up and running! Visit [http://localhost:3000](http://localhost:3000) and you’re ready to go.

### Run the worker

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

### Run the tests

#### Ruby

This uses a standard `RSpec` and `RuboCop` stack. To run these together:

```bash
bundle exec rake
```

To run only RSpec:

```bash
bundle exec rspec
```

To run only RuboCop:

```bash
bundle exec rubocop
```

#### JavaScript

```bash
npm test
```

The full test suite including linting can be run as parallel tasks using the command:

```bash
yarn test
```

To run unit tests written using [Jest](https://jestjs.io/):

```bash
yarn run js:test
```

To generate a coverage report of unit tests you can run:

```bash
yarn run js:test:coverage
```

Linting of Javascript files uses [ESLint](https://eslint.org/) and the ruleset is extended using [Airbnb rules](https://www.npmjs.com/package/eslint-config-airbnb) which are widely acknowledged as a comprehensive ruleset for modern Javascript. To run Javascript linting:

```bash
yarn run js:lint
```

#### SASS

Linting of SASS files uses [Stylelint](https://stylelint.io/) default ruleset and can be run using:

```bash
yarn run sass:lint
```

---

## Troubleshooting

* I see Page Not Found when I log in and try to create a job listing.

Try [importing the school data](#gias-data-schools-trusts-and-local-authorities) if you have not already. When your sign in account was created, it was assigned to a school via a URN, and you may not have a school in your database with the same URN.

---

## Misc

### Getting production-like data for local development

You can use conduit to create a dump of production data. See [this section](/documentation/hosting.md#backuprestore-govuk-paas-postgres-service-database) of the GovUK PaaS docs. Then you can load this into your local database:

```bash
psql tvs_development < backup.sql
```

### Calculating and storing homepage vacancy facets for local development

Inside the rails console:

```ruby
VacancyFacets.new.refresh
```

### Integration between Jira and Github

The integration allows to see the status of development from within the jira issue. You can see the
status of branches, commits and pull requests as well as navigate to them to show the detail in Github.

To enable this, the following formatting must be used:
- Branch: Prefix with the issue id. Ex: `TEVA-1155-test-jira-github-integration`
- Commit: Prefix with the issue id between square bracket. Ex: `[TEVA-1155] Update Readme`
- Pull request: Prefix with the issue id between square bracket. If the branch was prefixed correctly,
this should be automatically added for you. Ex: `[TEVA-1155] Document Jira-Github integration`

The branch, commit or pull request will then appear in the `Development` side panel within the issue.
