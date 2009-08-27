module JsonMatchers
  class JsonMatcher
    def initialize(json)
      @json = ActiveSupport::JSON.decode(json)
    end
    
    def matches?(hash)
      @hash = hash
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
        result = source.map{ |item| hash_scan(item, match) }.include?(true)
      elsif source.class == Hash
        if match.keys.detect{ |key| source.has_key?(key.to_s) }
          # TODO : clean this up. There has to be some magic ruby Hash method to reduce this
          keys = match.keys.map(&:to_s).sort
          source_values = source.select{|k,v| keys.include?(k)}.flatten.delete_if{|i|keys.include?(i)}
          match_values = match.values
          result = (source_values == match_values)
        else
          result = source.map{ |key,val| hash_scan(val, match) if val.class == Hash }.include?(true)
        end
      end
      result # yeah, it's unnecessary but helpful to figure out what's happening
    end
  end
  
  def match_json(json)
    JsonMatcher.new(json)
  end
end