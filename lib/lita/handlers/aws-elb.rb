module Lita
  module Handlers
    class AwsElbHandler < AwsBaseHandler

      help = { 'aws elbs[ --profile NAME]' => 'List all ELB.'}
      route(/aws elbs[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        data = exec_cli_json('elb describe-load-balancers', opts)
        res = data['LoadBalancerDescriptions'].map do |elb|
          { name: elb['LoadBalancerName'],
            dns: elb['DNSName'],
            listeners: elb['ListenerDescriptions'].map { |l| l['Listener']['Protocol'] },
            instances: elb['Instances'].map { |i| i['InstanceId'] },
            instance_count: elb['Instances'].count
          }
        end
        render(response, format_hash_list_with_title(:name, res))
      end

      help = { 'aws elb {ELB name}[ --profile NAME]' => 'Show single ELB details.' }
      route(/aws elb ([^ ]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        elb = response.matches.first[0]
        data = exec_cli_json('elb describe-load-balancers --load-balancer-names ' + elb, opts)
        instance_ids = data['LoadBalancerDescriptions'].map { |e| e['Instances'].map { |i| i['InstanceId'] } }.flatten
        if instance_ids.size > 0
          instances = exec_cli_json("ec2 describe-instances --instance-ids \"#{instance_ids.join('" "')}\"", opts)
          instances = instances['Reservations'].map { |r| r['Instances'] }.flatten
        else
          instances = []
        end
        res = instances.map { |instance| ec2_to_hash(instance) }
        render(response, "ELB #{elb} instances:\n" + format_hash_list_with_title(:name, res))
      end

      help = { 'aws elb-remove-instance {ELB name} {Instance ID}[ --profile NAME]' => 'Remove instance from ELB' }
      route(/aws elb\-remove\-instance ([^ ]+)[ ]+([i][\-][^ ]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        elb = response.matches.first[0]
        ec2 = response.matches.first[1]
        data = exec_cli_json("elb deregister-instances-from-load-balancer --load-balancer-name #{elb} --instances #{ec2}", opts)
        render(response, "removed!\nType `aws elb #{elb} #{response.matches.first[2]}` to check current online instances.")
      end

      help = { 'aws ele-add-instance {ELB name} {Instance ID}[ --profile NAME]' => 'Attach instance to ELB.' }
      route(/aws elb\-add\-instance ([^ ]+)[ ]+([i][\-][^ ]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        elb = response.matches.first[0]
        ec2 = response.matches.first[1]
        data = exec_cli_json("elb register-instances-with-load-balancer --load-balancer-name #{elb} --instances #{ec2}", opts)
        render(response, "Attached!\nType `aws elb #{elb} #{response.matches.first[2]}` to check current online instances.")
      end

      Lita.register_handler(AwsElbHandler)
    end
  end
end
