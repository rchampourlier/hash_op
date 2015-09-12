require 'hash_op/deep'

# Performs filtering operation on hash or array of hashes
module HashOp
  module Filter

    # Filters an array of hashes according to criteria
    # on the values of each hash.
    #
    # Check the README for examples.
    #
    # @param [Array] hashes array of hashes to be filtered
    # @param [Hash] criteria the method uses ::match?, see
    #   definition for more details
    # @return [Array]
    #
    def filter(hashes, criteria = {})
      hashes.select do |item|
        match?(item, criteria)
      end
    end
    module_function :filter

    # Applies ::filter on the value of an hash
    #
    # @param [Hash] hash the hash to be filtered
    # @param [String, Symbol] the path of the array of hashes
    #   inside hash to be filtered. Accessed through
    #   HashOp::Deep (path like 'path.to.some.key').
    # @param [Hash] criteria to filter on (performed through
    #   ::filter, so see the method for more details)
    # @return [Hash] the hash with values in array at path
    #   filtered according to criteria
    def filter_deep(hash, path, criteria = {})
      array = HashOp::Deep.fetch hash, path
      raise "Can\'t filter hash at path \"#{path}\", value is not an array" unless array.is_a?(Array)

      filtered_array = filter(array, criteria)
      HashOp::Deep.merge hash, path, filtered_array
    end
    module_function :filter_deep

    # @param [Hash] hash to match against criteria
    # @param [Hash] criteria to match the hash against
    #   each criteria is an hash
    #   { path => matching_object }, where:
    #     - path [String, Symbol] is used to access the value
    #       in the filtered object (through HashOp::Deep::fetch)
    #     - matching_object [Object] the object defining the
    #       match:
    #       * a Proc which will be called with the value and
    #         which should return true to indicate a match, else
    #         false,
    #       * a Regexp will be matched using the regexp match
    #         operator,
    #       * any other value will be matched against the
    #         equality operator.
    def match?(hash, criteria)
      unless hash.is_a?(Hash)
        fail ArgumentError, 'First argument must be an Hash'
      end
      return true if criteria.blank?

      criteria.map do |path, matching_object|
        value = HashOp::Deep.fetch(hash, path)
        case
        when matching_object.is_a?(Proc)
          matching_object.call(value)
        when matching_object.is_a?(Regexp)
          (value =~ matching_object).present?
        else value == matching_object
        end
      end.uniq == [true]
    end
    module_function :match?
  end
end
