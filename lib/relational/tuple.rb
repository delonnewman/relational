module Relational
  class Tuple < Hash
    def to_proc
      lambda do |key|
        fetch(key, nil)
      end
    end

    def method_missing(meth, *args)
      if keys.include?(meth)
        fetch(meth, nil)
      else
        raise "Undefined method #{meth}"
      end
    end
    
    alias to_a values
  end
end