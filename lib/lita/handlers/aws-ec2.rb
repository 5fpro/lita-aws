module Lita
  module Handlers
    class AwsEc2 < AwsBaseHandler

      help = { 'aws ec2-instances[ --profile NAME]' => 'List instances on EC2.'}
      route(/aws ec2\-instances[ ]*(.*)$/, help: help) do |response|
        data = exec_cli_json('ec2 describe-instances', get_options(response))
        instances = data['Reservations'].map do |tmp|
          tmp['Instances'].map { |instance| ec2_to_hash(instance) }
        end.flatten
        response.reply format_hash_list_with_title(:name, instances)
      end

      help = { 'aws ec2-create-ami {Instance ID} {AMI name}[ --profile NAME]' => 'Create AMI from EC2 instance.' }
      route(/aws ec2\-create\-ami ([i][\-][^ ]+)[ ]+([^ ]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        instance_id = response.matches.first[0]
        ami_name = response.matches.first[1]
        data = exec_cli_json("ec2 create-image --instance-id #{instance_id} --name #{ami_name} --no-reboot", opts)
        ami_id = data['ImageId']
        render response, "Your AMI ID: #{ami_id}"
      end

      help = { 'aws ec2-ami {AMI ID}[ --profile NAME]' => 'Show AMI detail.' }
      route(/aws ec2\-ami ([a][m][i][\-][^ ]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        ami_id = response.matches.first[0]
        data = exec_cli_json("ec2 describe-images --image-ids #{ami_id}", opts)
        data = data['Images'].map { |img| ami_to_hash(img) }
        render response, format_hash_list_with_title(:name, data)
      end

      help = { 'aws ec2-amis[ --profile NAME]' => 'Show AMI detail.' }
      route(/aws ec2\-amis[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        data = exec_cli_json("ec2 describe-images --owners #{account_id(opts)}", opts)
        data = data['Images'].map { |img| ami_to_hash(img) }
        render response, format_hash_list_with_title(:name, data)
      end

      Lita.register_handler(AwsEc2)
    end
  end
end
