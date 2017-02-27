# lita-aws

[![Build Status](https://travis-ci.org/5fpro/lita-aws.png?branch=master)](https://travis-ci.org/5fpro/lita-aws)
[![Coverage Status](https://coveralls.io/repos/5fpro/lita-aws/badge.png)](https://coveralls.io/r/5fpro/lita-aws)
[![Code Climate](https://codeclimate.com/github/5fpro/lita-aws/badges/gpa.svg)](https://codeclimate.com/github/5fpro/lita-aws)
[![Issue Count](https://codeclimate.com/github/5fpro/lita-aws/badges/issue_count.svg)](https://codeclimate.com/github/5fpro/lita-aws)

## Installation

Add lita-aws to your Lita instance's Gemfile:

``` ruby
gem 'lita-aws'
```

## System requirement

1. [AWS-CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) must be installed, make sure your lita user can execute `aws`.


## Configuration

- lita-aws support multiple aws accounts, configurating through aws-cli, you can use following commands to manage aws accounts.


#### List saved accounts

```
(lita) aws profile
```

#### Create or update account.

```
(lita) aws profile [profile_name] [region] [api_key] [secret_key]
```

- profile_name: Only accept lower letter and numbers. `default` will set to aws-cli default profile.
- region: AWS region, such as: `ap-northeast-1`
- api_key: AWS access key id.
- secret_key: AWS secret access key.

Example:

```
(lita) aws profile 5fpro ap-northeast-1 abcdefg ababcdcd
```

## Usage

#### Get AWS account number.

```
# with default profile
(lita) aws account-id
# with specific profile
(lita) aws account-id --profile {profile_name}
# Example:
(lita) aws account-id --profile 5fpro
```

# Execute as aws-cli

```
(lita) aws-cli ec2 describe-instances --page-size 10 --profile {profile_name}
```

That will execute as command line:

```
aws ec2 describe-instances --page-size 10 --profile {profile_name}
```

and return json.


## Customized commands usage

- `lita-aws` provide customized commands for re-composing json data and formatting output to human-readable response. All of these customized command will use `aws ` as command prefix.

- Here is the exmaple to get cloudwatch data:

#### Get cloudwatch metric data.

- Get EC2 instance memory utilization from Cloudwatch.

```
(lita) aws ec2-memutil {Instance ID} --ago 2d --cal Average --period 300s --profile {profile_name}
```

output:

```
2017-02-26T16:00:00Z : 45.56%
2017-02-26T16:05:00Z : 39.58%
2017-02-26T16:10:00Z : 39.32%
2017-02-26T16:15:00Z : 39.33%
2017-02-26T16:20:00Z : 39.55%
2017-02-26T16:25:00Z : 39.65%
2017-02-26T16:30:00Z : 39.72%
2017-02-26T16:35:00Z : 39.69%
2017-02-26T16:40:00Z : 39.68%
2017-02-26T16:45:00Z : 39.69%
2017-02-26T16:50:00Z : 39.68%
2017-02-26T16:55:00Z : 39.71%
```

options:

- ago: `2d` means get 2 days ago data. Currently, the unit only `d` as `day`.
- period: `300s` means each data contains 300 seconds.
- cal: `Averages` means each period data will calculate its average as output value. To see more values http://docs.aws.amazon.com/cli/latest/reference/cloudwatch/get-metric-statistics.html and find `--statistics`.

## More customized commands

```
(lita) help aws
# or
(lita) help aws elb
(lita) help aws ec2
(lita) help aws rds
....

```

## (For Mac OS users) Disable double dash auto converting

- For Mac OS users, if you try to type double dash (i.e. `--`) on Slack messasge input field, it would auto convert to emdash (i.e. `—`), please disable it. (Ref: http://superuser.com/questions/555628/how-to-stop-mac-to-convert-typing-double-dash-to-emdash)
