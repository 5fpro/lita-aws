module Lita
  module Handlers
    class AwsCloudWatchHandler < AwsBaseHandler

      help = { 'aws ec2-memutil [instance id][ --ago 2d][ --cal Average|SampleCount|Sum|Minimum|Maximum][ --period 300s][ --profile NAME]' => 'Show memory utilization of instance from days ago to now (default: 2 days).' }
      route(/aws ec2\-memutil ([i][\-][0-9a-zA-Z]+)[ ]*(.*)$/, help: help) do |response|
        opts = get_options(response)
        ago = opts.delete(:ago) || '2d'
        statistics = opts.delete(:cal) || 'Average'
        period = (opts.delete(:period) || '300s').to_i
        instance_id = response.matches.first.first
        start_time = (Time.now - (ago.to_i) * (60 * 60 * 24)).utc.strftime("%Y-%m-%dT%H:00")
        end_time = Time.now.utc.strftime("%Y-%m-%dT%H:00")
        cmd = "cloudwatch get-metric-statistics --namespace System/Linux --metric-name MemoryUtilization --dimensions Name=InstanceId,Value=#{instance_id} --start-time #{start_time} --end-time #{end_time} --period #{period} --statistics #{statistics}"
        data = exec_cli_json(cmd, opts)['Datapoints'].map { |d| [ d['Timestamp'], "#{d[statistics].round(3)}%"] }.sort_by { |d| Time.parse(d[0]).to_i }
        render(response, format_timeline(data))
      end

      Lita.register_handler(AwsCloudWatchHandler)
    end
  end
end
