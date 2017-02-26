module LitaAws
  module Parser

    protected

    def get_options(response)
      parse_options(response.matches.first.last.to_s)
    end

    def parse_options(opt_str)
      opt_str.scan(/\-\-([ a-zA-Z0-9\-]+?)[ ]+([^ ]+)/).inject({}) do |h, groups|
        h.merge(groups[0].to_sym => groups[1])
      end
    end

  end
end
