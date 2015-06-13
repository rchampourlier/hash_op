module HashOp
  module Merge

    # Merge all specified hashes by merging the second
    # in the first, the third in the result, and so on.
    def merge(hashes)
      hashes.inject({}) do |result, hash|
        result.merge hash
      end
    end
    module_function :merge

    # Merge hashes by grouping them on the
    # specified key value and merging them all together.
    def merge_by_group(hashes, key)
      groups = hashes.group_by { |h| h[key] }
      groups.values.map { |g| merge(g) }
    end
    module_function :merge_by_group
  end
end
