module HashOp
  module Merge

    # Merge all specified hashes by merging the second
    # in the first, the third in the result, and so on.
    def flat(hashes)
      hashes.inject({}) do |result, hash|
        result.merge hash
      end
    end
    module_function :flat

    # Merge hashes by grouping them on the
    # specified key value and merging them all together.
    def by_group(hashes, key)
      groups = hashes.group_by { |h| h[key] }
      groups.values.map { |g| flat(g) }
    end
    module_function :by_group
  end
end
