require 'json'
$bin_aws = `which aws`.gsub("\n", '')
$bin_aws = '~/.local/bin/aws' if $bin_aws.index(' ') || $bin_aws.to_s.length == 0

module LitaAws
  module Base

    protected

    def exec_cli(cmd, opts = {})
      cmd_postfix = opts.to_a.map { |e| "--#{e.first} #{e.last}" }.join(' ')
      cmd = cmd.delete(';')
      cmd_postfix = cmd_postfix.delete(';')
      `#{$bin_aws} #{cmd} #{cmd_postfix}`
    end

    def exec_cli_json(cmd, opts = {})
      JSON.parse exec_cli(cmd, opts)
    end

    def add_error(msg, objects = nil)
      @errors ||= []
      @errors << { msg: msg, objects: objects }
    end

    def render(response, text)
      if text
        response.reply(text)
      else
        response.reply("[Fail] #{@errors.map(&:to_s).join("\n")}")
      end
    end

  end
end
