module Lita
  module Handlers
    class Aws < Handler
      include ::LitaAws::Base

      help = { 'aws [service] help' => 'Get command options help of [service].' }
      route(/aws (.+) help$/, help: help) do |response|
        service = response.matches[0][0]
        text = exec_cli("#{service} help|cat")
        response.reply(text.gsub("\n\n", "\n"))
      end

      help = { 'aws-cli [command]' => 'Execute aws-cli.' }
      route(/aws\-cli (.+)$/, help: help) do |response|
        response.reply(exec_cli(response.matches.first[0]))
      end

      Lita.register_handler(self)
    end
  end
end
