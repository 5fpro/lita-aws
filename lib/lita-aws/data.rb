require 'json'
module LitaAws
  module Data
    protected

    def ec2_to_hash(instance)
      {
        instance_id: instance['InstanceId'],
        name: instance['Tags'].select { |d| d['Key'] == 'Name' }.first['Value'],
        public_dns: instance['PublicDnsName'],
        public_ip: instance['PublicIpAddress'],
        state: instance['State']['Name'],
        security_group: instance['SecurityGroups'].first['GroupName'],
        type: instance['InstanceType']
      }
    end

    def ami_to_hash(ami)
      {
        name: ami['Name'],
        id: ami['ImageId'],
        state: ami['State'],
        type: ami['ImageType'],
        desc: ami['Description']
      }
    end
  end
end
