module Lita
  module Handlers
    class AwsBaseHandler < Handler
      include ::LitaAws::Base
      include ::LitaAws::ReplyFormatter
      include ::LitaAws::Parser
      include ::LitaAws::Data
      include ::LitaAws::Scripts
    end
  end
end
