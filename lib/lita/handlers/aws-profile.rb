module Lita
  module Handlers
    class AwsProfile < AwsBaseHandler

      help = { 'aws profile' => 'list all aws profile.'}
      route(/aws profile$/, help: help) do |response|
        config_text = `cat ~/.aws/config`
        profiles = ['default'] + config_text.scan(/\[profile ([a-z0-9A-Z\-_]+)\]\n/).map(&:first)
        attrs = ['region', 'aws_access_key_id']
        results = profiles.inject({}) do |h, e|
          h.merge(e => attrs.inject({}) do |hh, ee|
            profile = e == 'default' ? '' : "--profile #{e}"
            hh.merge(ee => `aws configure get #{ee} #{profile}`.gsub("\n", ''))
          end)
        end
        lines = results.to_a.inject([]) { |a, e| a + ["#{e[0]}: #{e[1].values.join(', ')}"] }
        response.reply(lines.join("\n"))
      end

      help = { 'aws profile {name} {region} {api key} {secret key}' => 'Create or update aws profile credentials and region. If use \'default\' as name, it would set to default profile.'}
      route(/aws profile ([a-zA-Z\-0-9]+) ([a-z\-0-9]+) ([^ ]+) ([^ ]+)/, help: help) do |response|
        name, @region, @aws_access_key_id, @aws_secret_access_key = response.matches.first
        cmd_postfix = name == 'default' ? '' : "--profile #{name}"
        ['region', 'aws_access_key_id', 'aws_secret_access_key'].each do |attr|
          `aws configure set #{attr} #{instance_variable_get("@#{attr}")} #{cmd_postfix}`
        end
        response.reply("Set profile #{name}:\n  region: #{@region}\n  aws_access_key_id: #{@aws_access_key_id}\n  aws_secret_access_key: #{@aws_secret_access_key}")
      end

      help = { 'aws account-id[ --profile NAME]' => 'Get your aws account id.' }
      route(/aws account\-id[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        render response, "Your AWS account id: #{account_id(opts)}"
      end

      Lita.register_handler(AwsProfile)
    end
  end
end
