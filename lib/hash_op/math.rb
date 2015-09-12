require 'hash_op/deep'

# A set of functions to perform mathematical operations
# on Hashes.
module HashOp
  module Math

    # Sum values in an array of hashes by grouping on a given
    # key.
    #
    # Example:
    #   hashes = [
    #     { group_1: :a, group_2: :a, value_1: 1, value_2: 1 },
    #     { group_1: :a, group_2: :b, value_1: 1, value_2: 2 },
    #     { group_1: :a, group_2: :b, value_1: 1, value_2: 2 },
    #     { group_1: :b, group_2: :c, value_1: 1, value_2: 3 }
    #   ]
    #   HashOp::Math.sum_on_groups(hashes,
    #     [:group_1], [:value_1, :value_2]
    #   )
    #   => [
    #     { group_1: :a, value_1: 3, value_2: 5 },
    #     { group_1: :b, value_1: 1, value_2: 3 }
    #   ]
    #   HashOp::Math.sum_on_groups(hashes,
    #     [:group_1, :group_2], [:value_1, :value_2]
    #   )
    #   => [
    #     { group_1: :a, group_2: :a, value_1: 1, value_2: 1 },
    #     { group_1: :a, group_2: :b, value_1: 2, value_2: 4 },
    #     { group_1: :b, group_2: :c, value_1: 1, value_2: 3 }
    #   ]
    #
    # @param hashes [Array] the hashes to be summed
    # @param group_key [Object] the key to use to group items on
    # @param value_key [Object] the key of the values to sum
    # @return [Array]
    def sum_on_groups(hashes, grouping_paths, value_paths)
      grouped_hashes = Grouping.group_on_paths(hashes, grouping_paths)
      group_paths = Deep.paths(grouped_hashes)
      result = group_paths.map do |group_path|
        group_hashes = HashOp::Deep.fetch(grouped_hashes, group_path)
        group_values = value_paths.map do |value_path|
          group_value = HashOp::Math.sum_at_path(group_hashes, value_path)
          { value_path => group_value }
        end
        Hash[[grouping_paths, group_path].transpose].merge(Merge.flat(group_values))
      end
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
