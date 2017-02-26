require 'json'
module LitaAws
  module Base

    protected

    def exec_cli(cmd, opts = {})
      cmd_postfix = opts.to_a.map { |e| "--#{e.first} #{e.last}"}.join(' ')
      `aws #{cmd} #{cmd_postfix}`
    end

    def exec_cli_json(cmd, opts = {})
      JSON.parse exec_cli(cmd, opts)
    end

    def render(response, text)
      # TODO: debug here
      response.reply(text)
    end
  end
end
