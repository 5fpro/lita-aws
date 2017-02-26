require 'json'
module Lita
  module Handlers
    class Aws < Handler
      help = { 'aws [service] help' => 'Get command options help of [service].' }
      route(/aws (.+) help$/, help: help) do |response|
        service = response.matches[0][0]
        text = `aws #{service} help|cat`
        response.reply(text.gsub("\n\n", "\n"))
      end

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

      help = { 'aws profile [name] [region] [api key] [secret key]' => 'Create or update aws profile credentials and region. If use \'default\' as name, it would set to default profile.'}
      route(/aws profile ([a-zA-Z\-0-9]+) ([a-z\-0-9]+) ([^ ]+) ([^ ]+)/, help: help) do |response|
        name, @region, @aws_access_key_id, @aws_secret_access_key = response.matches.first
        cmd_postfix = name == 'default' ? '' : "--profile #{name}"
        ['region', 'aws_access_key_id', 'aws_secret_access_key'].each do |attr|
          `aws configure set #{attr} #{instance_variable_get("@#{attr}")} #{cmd_postfix}`
        end
        response.reply("Set profile #{name}:\n  region: #{@region}\n  aws_access_key_id: #{@aws_access_key_id}\n  aws_secret_access_key: #{@aws_secret_access_key}")
      end

      help = { 'aws ec2-instances[ --profile NAME]' => 'List instances on EC2.'}
      route(/aws ec2\-instances[ ]*(.*)$/, help: help) do |response|
        data = execute_cli_json('ec2 describe-instances', fetch_profile(response))
        instances = data['Reservations'].map do |tmp|
          tmp['Instances'].map do |instance|
            {
              instance_id: instance['InstanceId'],
              name: instance['Tags'].select { |d| d['Key'] == 'Name' }.first['Value'],
              public_dns: instance['PublicDnsName'],
              public_ip: instance['PublicIpAddress'],
              state: instance['State']['Name'],
              sg: instance['SecurityGroups'].first['GroupName'],
              type: instance['InstanceType'],

            }
          end
        end.flatten
        response.reply(format_list(instances, :name))
      end

      help = { 'aws-cli [command]' => 'Execute aws-cli.' }
      route(/aws\-cli (.+)$/, help: help) do |response|
        response.reply(`aws #{response.matches.first[0]}`)
      end

      private

      def fetch_profile(response)
        response.matches.first.last.to_s.split('--profile ').last
      end

      def execute_cli(cmd, profile)
        cmd_postfix = profile ? "--profile #{profile}" : ''
        data = `aws #{cmd} #{cmd_postfix}`
        data
      end

      def execute_cli_json(cmd, profile)
        JSON.parse(execute_cli(cmd, profile))
      end

      def format_list(list, title_key)
        lines = []
        list.each do |e|
          lines << e[title_key]
          e.reject { |k, _| k == title_key }.each do |col, v|
            lines << "  #{col}: #{v}"
          end
        end
        lines.join("\n")
      end

      Lita.register_handler(self)
    end
  end
end
