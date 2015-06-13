require 'hash_op/deep_access'

# A module to perform mapping from hash to hash.
module HashOp
  module Mapping

    # @param hash [Hash] the hash to map
    # @param mapping [Hash] the mapping to use to perform the
    #   mapping (see example below)
    #   A mapping hash is:
    #     a_key [String or Symbol] => a_mapping_item [Hash]
    #   A mapping item is:
    #     path: [String or Symbol] the path to the value
    #     type: [:time or :array]
    #     item_mapping: [Hash] for a mapping item whose type
    #       is :array when the array items are hashes to be
    #       mapped again. This mapping can be done with any
    #       level of recursion.
    #
    # Example of a mapping hash:
    # {
    #   int:  { path: :'root.integer' },
    #   str:  { path: :'root.string' },
    #   time: { path: :'root.deep_1.deep_2.time', type: :time },
    #   strings: { path: :'root.array_of_strings' },
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
