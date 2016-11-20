# frozen_string_literal: true

# Provides ::fetch and ::merge methods which allows
# to perform fetch/merge operations deeply in Hash
# through a path in the form of 'a.b.c' or an array
# of segments ['a', 'b', 'c'].
module HashOp
  module Deep

    # Examples:
    #     h = {a: {b: {c: 1}}}
    #     HashOp::Deep.fetch(h, :a) # => {:b=>{:c=>1}}
    #     HashOp::Deep.fetch(h, :'a.b') # => {:c=>1}
    #     HashOp::Deep.fetch(h, :'a.b.c') # => 1
    #     HashOp::Deep.fetch(h, [:a]) # => {:b=>{:c=>1}}
    #     HashOp::Deep.fetch(h, [:a, :b, :c]) # => 1
    #     HashOp::Deep.fetch(h, :'b.c.a') # => nil
    #
    def fetch(hash, path)
      raise ArgumentError, "First argument must be an Hash (was #{hash})" unless hash.is_a?(Hash)
      if [String, Symbol].include?(path.class)
        fetch_with_deep_key(hash, path)
      elsif path.is_a? Array
        fetch_with_segments(hash, path)
      else
        raise ArgumentError, 'Invalid attribute, must be a String or an Array'
      end
    end
    module_function :fetch

    # Examples:
    #   h = {}
    #   h = HashOp::Deep.merge(h, :a, 1)
    #   => { :a => 1 }
    #   h = HashOp::Deep.merge(h, :'a.b', 2)
    #   => { :a => { :b => 2 }
    #   h = HashOp::Deep.merge(h, :b, 3)
    #   => { :a => { :b => 2 }, :b => 3 }
    def merge(hash, path, value)
      raise ArgumentError, 'First argument must be an Hash' unless hash.is_a? Hash
      if [String, Symbol].include?(path.class)
        merge_with_deep_key(hash, path, value)
      elsif path.is_a? Array
        merge_with_segments(hash, path, value)
      else
        raise 'Invalid attribute, must be a String or an Array'
      end
    end
    module_function :merge

    # Example:
    #   hash = { a: { :b => 1, 'c' => 2 }, d: 0 }
    #   HashOp::Deep.paths(hash)
    #   => [[:a, :b], [:a, 'c' ], [:d]]
    def paths(hash)
      r = []
      hash.each do |key, value|
        if value.is_a?(Hash)
          paths(value).each do |deep_key|
            r << [key] + Array(deep_key)
          end
        else r << Array(key)
        end
      end
      r.uniq
    end
    module_function :paths

    private

    def fetch_with_deep_key(hash, deep_key)
      segments = deep_key.to_s.split('.')
      segments.map!(&:to_sym) if deep_key.is_a? Symbol
      fetch_with_segments(hash, segments)
    end
    module_function :fetch_with_deep_key

    def fetch_with_segments(hash, segments)
      return hash if segments.empty?

      result = hash[segments.first]
      if result.is_a? Hash
        fetch_with_segments(result, segments[1..-1])
      elsif result.is_a? Array
        result.map do |item|
          fetch_with_segments(item, segments[1..-1])
        end
      else
        result
      end
    end
    module_function :fetch_with_segments

    def merge_with_deep_key(hash, deep_key, value)
      segments = deep_key.to_s.split('.')
      segments.map!(&:to_sym) if deep_key.is_a? Symbol
      merge_with_segments(hash, segments, value)
    end
    module_function :merge_with_deep_key

    def merge_with_segments(hash, segments, value)
      current_segment = segments.first
      remaining_segments = segments[1..-1]

      return value if segments.empty?

      current_value = hash[current_segment]
      new_value = (
        if remaining_segments.length > 0
          if current_value.is_a? Hash
            merge_with_segments(current_value, remaining_segments, value)
          elsif current_value.is_a? Array
            current_value.map do |item|
              merge_with_segments(item, remaining_segments, value)
            end
          else
            build_with_segments remaining_segments, value
          end
        else value
        end
      )
      hash.merge current_segment => new_value
    end
    module_function :merge_with_segments

    def build_with_segments(segments, value)
      return value if segments.empty?
      { segments.first => build_with_segments(segments[1..-1], value) }
    end
    module_function :build_with_segments
  end
end
