require 'hash_op/deep'

# A set of functions to perform mathematical operations
# on Hashes.
module HashOp
  module Math

    # @param hashes [Array] of Hash instances
    # @return [Hash] summing values of the same key
    def sum(*hashes)
      hashes.flatten!
      case hashes.length
      when 0 then {}
      when 1 then hashes.first
      when 2 then sum_two(*hashes)
      else
        sum(*[sum_two(*hashes[0..1])] + hashes[2..-1])
      end
    end
    module_function :sum

    def sum_two(hash_a, hash_b)
      hash_b.each do |key, hash_b_value|
        if hash_a[key]
          hash_a[key] += hash_b_value
        else
          hash_a[key] = hash_b_value
        end
      end
      hash_a
    end
    module_function :sum_two

    # Sum values in an array of hashes by grouping on a given
    # key.
    #
    # Example:
    #   hashes = [
    #     { group: :a, value: 1 },
    #     { group: :a, value: 1 },
    #     { group: :b, value: 1 }
    #   ]
    #   HashOp::Math.sum_on_groups(hashes, :group, :value)
    #   # => [
    #   #   { group: :a, value: 2 },
    #   #   { group: :b, value: 1 }
    #   # ]
    #
    # @param hashes [Array] the hashes to be summed
    # @param group_key [Object] the key to use to group items on
    # @param value_key [Object] the key of the values to sum
    # @return [Array]
    def sum_on_groups(hashes, group_key, value_key)
      work_hash = hashes.inject({}) do |work, hash|
        if work[hash[group_key]].nil?
          work[hash[group_key]] = {
            group_key => hash[group_key],
            value_key => hash[value_key]
          }
        else
          work[hash[group_key]][value_key] += hash[value_key]
        end
        work
      end
      work_hash.values
    end
    module_function :sum_on_groups

    # Sum values for the specified hashes at the specified path.
    # The values are added to the specified zero (defaults to numeric
    # 0), and nil values will be coerced to the zero too.
    #
    # @param hashes [Array]
    # @param path [String]
    # @param zero [Object] defaults to [Numeric] 0
    #
    def sum_at_path(hashes, path, zero = 0)
      hashes.inject(zero) do |sum, hash|
        value = HashOp::Deep.fetch(hash, path) || zero
        sum + value
      end
    end
    module_function :sum_at_path

    # @param [Array] hashes array of Hash
    # @param [String, Symbol] path to deep value in each hash
    def deep_min(hashes, path)
      hashes.map { |hash| HashOp::Deep.fetch hash, path }.min
    end
    module_function :deep_min

    # @param [Array] hashes array of Hash
    # @param [String, Symbol] path to deep value in each hash
    def deep_max(hashes, path)
      hashes.map { |hash| HashOp::Deep.fetch hash, path }.max
    end
    module_function :deep_max
  end
end
