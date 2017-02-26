module Lita
  module Handlers
    class AwsBaseHandler < Handler
      include ::LitaAws::Base
      include ::LitaAws::ReplyFormatter
      include ::LitaAws::Parser
    end
  end
end
