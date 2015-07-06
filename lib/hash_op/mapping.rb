require 'hash_op/deep_access'

# A module to perform mapping from hash to hash.
module HashOp
  module Mapping

    # @param hash [Hash] the hash to map
    # @param mapping [Hash] the mapping to use to perform the
    #   mapping (see example below)
    #   A mapping hash is:
    #     a_key [String or Symbol] => a_mapping_item [Hash]
    #   A mapping item is composed of:
    #     - path: [String or Symbol] the path to the value
    #     - type: [Symbol] defines how the item will be processed
    #       before being added to the result
    #       - `raw` (defaults, if no type specified): the value
    #         is passed with no transformation
    #       - `time`: the value is parsed using `Time.parse`
    #         (if the parse fails, nil is passed in the result,
    #         no exception raised)
    #       - `mapped_hash`: the value is mapped recursively,
    #         using the `mapping` key as the mapping
    #       - `parseable_string`: the string value is analyzed
    #         using regexps and each value extracted by a regexp
    #         can be recursively processed using mappings
    #         applicable to strings (e.g. time); the mapping
    #         to use for the parsing is defined in
    #         `parsing_mapping` (see the README for an example)
    #       - `array`: recursively apply a mapping over each
    #         item in the array; the mapping for each item is
    #         defined in `item_mapping`
    #     - mapping: for a mapping item of type `mapped_hash`
    #     - parsing_mapping: for a mapping item of type
    #       `parseable_string`
    #     - item_mapping: for a mapping item of type `array`
    #
    # Example of a mapping hash:
    # {
    #   raw:  { path: :'root.value' },
    #   time: { path: :'root.deep_1.deep_2.time', type: :time },
    #   mapped_hashes: {
    #     path: :'root.array_of_mapped_hashes',
    #     type: :array,
    #     item_mapping: {
    #       str:  { path: :'root.string' },
    #       time: { path: :'root.deep_1.time', type: :time }
    #     }
    #   }
    # }
    #
    def apply_mapping(hash, mapping)
      mapping.keys.inject({}) do |mapped_hash, key|
        mapping_item = mapping[key]
        path = mapping_item[:path]
        raise "path not found in mapping item #{mapping_item}" if path.nil?
        raw = HashOp::DeepAccess.fetch(hash, path)
        processed = process_with_mapping_item(raw, mapping_item)
        mapped_hash[key] = processed
        mapped_hash
      end
    end
    module_function :apply_mapping

    def process_with_mapping_item(raw_value, mapping_item)
      type = mapping_item[:type] || :raw
      send :"process_with_mapping_item_#{type}", raw_value, mapping_item
    end
    module_function :process_with_mapping_item

    def process_with_mapping_item_raw(value, mapping_item)
      value
    end
    module_function :process_with_mapping_item_raw

    def process_with_mapping_item_time(value, mapping_item)
      return nil if value.nil?
      begin
        Time.parse value
      rescue ArgumentError
        nil
      end
    end
    module_function :process_with_mapping_item_time

    def process_with_mapping_item_mapped_hash(value, mapping_item)
      return {} if value.nil?
      mapping_item_mapping = mapping_item[:mapping]
      raise "Missing mapping for mapped_hash \"#{value}\"" if mapping_item_mapping.nil?

      apply_mapping(value, mapping_item_mapping)
    end
    module_function :process_with_mapping_item_mapped_hash

    def process_with_mapping_item_parseable_string(value, mapping_item)
      return {} if value.nil?
      parsing_mapping = mapping_item[:parsing_mapping]
      raise "Missing parsing_mapping for mapping #{mapping_item}" if parsing_mapping.nil?
      parsing_results = parsing_mapping.map do |parsing_key, parsing_options|
        regexp = Regexp.new parsing_options[:regexp]
        match = regexp.match(value)
        result = match ? process_with_mapping_item(match[1], parsing_options) : nil
        [parsing_key, result]
      end
      Hash[parsing_results]
    end
    module_function :process_with_mapping_item_parseable_string

    def process_with_mapping_item_array(value, mapping_item)
      return [] if value.nil?
      item_mapping = mapping_item[:item_mapping]
      raise "Missing item mapping for array \"#{value}\"" if item_mapping.nil?
      value.map do |item|
        process_with_mapping_item(item, item_mapping)
      end
    end
    module_function :process_with_mapping_item_array
  end
end
