module Lita
  module Handlers
    class AwsEc2 < AwsBaseHandler

      help = { 'aws ec2-instances[ --profile NAME]' => 'List instances on EC2.'}
      route(/aws ec2\-instances[ ]*(.*)$/, help: help) do |response|
        data = JSON.parse exec_cli('ec2 describe-instances', get_options(response))
        instances = data['Reservations'].map do |tmp|
          tmp['Instances'].map { |instance| ec2_to_hash(instance) }
        end.flatten
        response.reply format_hash_list_with_title(:name, instances)
      end

      Lita.register_handler(AwsEc2)
    end
  end
end
