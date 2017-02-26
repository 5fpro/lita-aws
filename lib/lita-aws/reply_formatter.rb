module LitaAws
  module ReplyFormatter

    protected

    def format_timeline(array)
    end

    def format_hash_list_with_title(title_key, hash_list)
      lines = []
      hash_list.each do |hash|
        lines << hash[title_key]
        hash.reject { |k, _| k == title_key }.each do |col, v|
          lines << "  #{col}: #{v}"
        end
      end
      lines.join("\n")
    end

  end
end
