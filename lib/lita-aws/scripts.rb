module LitaAws
  module Scripts
    protected

    def account_id(opts = {})
      unless @account_id
        data = exec_cli_json('ec2 describe-security-groups --group-names default', opts)
        @account_id = data['SecurityGroups'].first['OwnerId']
      end
      @account_id
    end
  end
end
