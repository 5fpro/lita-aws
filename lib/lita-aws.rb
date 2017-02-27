require 'lita'

Lita.load_locales Dir[File.expand_path(
  File.join('..', '..', 'locales', '*.yml'), __FILE__
)]

# modules
require 'lita-aws/version'
require 'lita-aws/base'
require 'lita-aws/reply_formatter'
require 'lita-aws/parser'
require 'lita-aws/data'
require 'lita-aws/scripts'

# handlers
require 'lita/handlers/aws-base-handler'
require 'lita/handlers/aws'
require 'lita/handlers/aws-profile'
require 'lita/handlers/aws-ec2'
require 'lita/handlers/aws-cloudwatch'
require 'lita/handlers/aws-elb'
# require 'lita/handlers/aws-rds'

Lita::Handlers::Aws.template_root File.expand_path(
  File.join('..', '..', 'templates'),
  __FILE__
)
