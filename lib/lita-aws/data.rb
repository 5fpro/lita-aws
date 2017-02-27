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

    def db_instance_to_hash(db)
      {
        name: db['DBInstanceIdentifier'],
        status: db['DBInstanceStatus'],
        engine: db['Engine'],
        version: db['EngineVersion'],
        connect_user: db['MasterUsername'],
        connect_endpoint: db['Endpoint']['Address'],
        connect_can_public: db['PubliclyAccessible'],
        has_multiaz: db['MultiAZ'],
        arn: db['DBInstanceArn'],
        size: "#{db['AllocatedStorage']} GB",
        type: db['DBInstanceClass']
      }
    end
  end
end
