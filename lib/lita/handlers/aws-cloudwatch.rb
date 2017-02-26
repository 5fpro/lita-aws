module Lita
  module Handlers
    class AwsCloudWatchHandler < AwsBaseHandler

      help = { 'aws ec2-memutil {instance id}[ --ago 2d][ --cal Average|SampleCount|Sum|Minimum|Maximum][ --period 300s][ --profile NAME]' => 'Show memory utilization of EC2 instance.' }
      route(/aws ec2\-memutil ([i][\-][0-9a-zA-Z]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options_for_cloudwatch(response, ago: '2d', period: '300s', cal: 'Average')
        instance_id = response.matches.first.first
        cmd = "cloudwatch get-metric-statistics --namespace System/Linux --metric-name MemoryUtilization --dimensions Name=InstanceId,Value=#{instance_id} --start-time #{opts[:start_time]} --end-time #{opts[:end_time]} --period #{opts[:period]} --statistics #{opts[:cal]}"
        data = exec_cli_json(cmd, opts[:cmd_opts])
        render_cloudwatch_data(response, data, opts[:cal])
      end

      help = { 'aws ec2-cpuutil {instance id}[ --ago 2d][ --period 300s][ --profile NAME]' => 'Show CPU utilization of EC2 instance.'}
      route(/aws ec2\-cpuutil ([i][\-][0-9a-zA-Z]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options_for_cloudwatch(response, ago: '2d', period: '300s')
        instance_id = response.matches.first.first
        cmd = "cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=#{instance_id} --start-time #{opts[:start_time]} --end-time #{opts[:end_time]} --period #{opts[:period]} --statistics Average"
        data = exec_cli_json(cmd, opts[:cmd_opts])
        render_cloudwatch_data(response, data, 'Average')
      end

      help = { 'aws elb-req-sum {ELB name}[ --ago 2d][ --period 300s][ --profile NAME]' => 'Show ELB request count.'}
      route(/aws elb\-req-sum ([0-9a-zA-Z_]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options_for_cloudwatch(response, ago: '2d', period: '300s')
        elb_name = response.matches.first.first
        cmd = "cloudwatch get-metric-statistics --namespace AWS/ELB --metric-name RequestCount --dimensions Name=LoadBalancerName,Value=#{elb_name} --start-time #{opts[:start_time]} --end-time #{opts[:end_time]} --period #{opts[:period]} --statistics Sum"
        data = exec_cli_json(cmd, opts[:cmd_opts])
        render_cloudwatch_data(response, data, 'Sum')
      end

      help = { 'aws rds-space {RDS Identifier}[ --profile NAME]' => 'Show RDS instance current disk space in GB.' }
      route(/aws rds\-space ([0-9a-zA-Z_]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options_for_cloudwatch(response)
        rds = response.matches.first.first
        start_time = (Time.now.utc - (12 * 60 * 60)).strftime("%Y-%m-%dT%H:00")
        end_time = Time.now.utc.strftime("%Y-%m-%dT%H:00")
        cmd = "cloudwatch get-metric-statistics --namespace AWS/RDS --metric-name FreeStorageSpace --dimensions Name=DBInstanceIdentifier,Value=#{rds} --start-time #{start_time} --end-time #{end_time} --period 120 --statistics Minimum"
        data = convert_datapoints(exec_cli_json(cmd, opts[:cmd_opts]), 'Minimum')
        render(response, "Free space of #{rds}:\n  #{(data.last || []).last}")
      end

      private

      def get_options_for_cloudwatch(response, defaults = {})
        results = {}
        opts = get_options(response)
        defaults.each { |k, v| results[k] = (opts.delete(k) || v) }

        if results[:ago]
          results[:start_time] = (Time.now - (results[:ago].to_i) * (60 * 60 * 24)).utc.strftime("%Y-%m-%dT%H:00")
          results[:end_time] = Time.now.utc.strftime("%Y-%m-%dT%H:00")
        end
        results[:period] = results[:period].to_i if results[:period]

        results[:cmd_opts] = opts
        results
      end

      def render_cloudwatch_data(response, data, cal = 'Average')
        data = convert_datapoints(data, cal)
        render(response, format_timeline(data))
      end

      def convert_datapoints(data, cal)
        data['Datapoints'].map do |d|
          unit = unit_name(d['Unit'])
          value = convert_value(d['Unit'], d[cal])
          [ d['Timestamp'], "#{value}#{unit}"]
        end.sort_by { |d| Time.parse(d[0]).to_i }
      end

      def unit_name(unit)
        case unit
        when 'Percent' then '%'
        when 'Bytes' then 'GB'
        else ''
        end
      end

      def convert_value(unit, value)
        case unit
        when 'Percent' then value.round(2)
        when 'Bytes' then (value / 1024 / 1024 / 1024).round(1)
        else value
        end

      end

      Lita.register_handler(AwsCloudWatchHandler)
    end
  end
end
