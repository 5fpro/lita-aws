module Lita
  module Handlers
    class AwsEc2 < AwsBaseHandler

      help = { 'aws ec2-instances[ --profile NAME]' => 'List instances on EC2.'}
      route(/aws ec2\-instances[ ]*(.*)$/, help: help) do |response|
        data = JSON.parse exec_cli('ec2 describe-instances', get_options(response))
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
        response.reply format_hash_list_with_title(:name, instances)
      end

      Lita.register_handler(AwsEc2)
    end
  end
end
