module RbInvoice
  module Util

    def self.symbolize_array(arr)
      arr.map{|x|
        case x
        when Hash; symbolize_hash(x)
        when Array; symbolize_array(x)
        else x
        end
      }
    end

    def self.symbolize_hash(h)
      h.each_with_object({}) {|(k,v), h|
        h[k.to_sym] = case v
                      when Hash; symbolize_hash(v)
                      when Array; symbolize_array(v)
                      else; v
                      end
      }
    end

    def self.read_with_yaml(text)
      symbolize_hash(YAML::load(text) || {})
    end

    def self.stringify_array(arr)
      arr.map{|x|
        case x
        when Hash; stringify_hash(x)
        when Array; stringify_array(x)
        else x
        end
      }
    end

    def self.stringify_hash(h)
      h.each_with_object({}) {|(k,v), h|
        h[k.to_s] = case v
                    when Hash; stringify_hash(v)
                    when Array; stringify_array(v)
                    else; v
                    end
      }
    end

  end
end
