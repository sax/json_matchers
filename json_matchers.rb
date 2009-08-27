module JsonMatchers
  class JsonMatcher
    def initialize(json)
      @json = ActiveSupport::JSON.decode(json)
    end
    
    def matches?(hash)
      @hash = hash.inject({}) {|memo, (k,v)| memo[k] = fix_type(v); memo }
      hash_scan(@json, @hash)
    end
    
    def failure_message
      "expected to find \n#{@hash.to_yaml}\n in JSON response, got \n#{@json.to_yaml}\n"
    end
    
    def negative_failure_message
      "expected not to find \n#{@hash.to_yaml}\n in JSON response, got \n#{@json.to_yaml}\n"
    end
    
    def hash_scan(source, match)
      if source.class == Array
        source.map{ |item| hash_scan(item, match) }.include?(true)
      elsif source.class == Hash
        if match.keys.detect{ |key| source.has_key?(key.to_s) }
          # TODO : clean this up. There has to be some magic ruby Hash method to reduce this
          # TODO : better sorting
          keys = match.keys.map(&:to_s).sort
          source_values = source.select{|k,v| keys.include?(k)}.sort.flatten.delete_if{|i|keys.include?(i)}
          match_values = match.values
          source_values.sort!{|a,b| a.to_s <=> b.to_s}
          match_values.sort!{|a,b| a.to_s <=> b.to_s}
          true & (source_values == match_values)
        else
          source.map{ |key,val| hash_scan(val, match) if val.class == Hash }.include?(true)
        end
      end
    end
    
    def fix_type(val)
      case val
        when val.to_i.to_s then val.to_i
        when "true" then true
        when "false" then false
        else val
      end
    end
  end
  
  def match_json(json)
    JsonMatcher.new(json)
  end
end