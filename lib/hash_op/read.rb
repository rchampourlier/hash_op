require 'hash_op/deep'

module HashOp

  # A set of method to read values in hashes.
  module Read

    # @param hashes [Array]
    # @param path [Array or String]
    def values_at_path(hashes, path)
      hashes.map { |hash| Deep.fetch(hash, path) }
    end
    module_function :values_at_path
  end
end
