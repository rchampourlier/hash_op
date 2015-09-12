require 'hash_op/deep'

# A module to perform group operations on hashes.
module HashOp
  module Grouping

    # @param hashes [Array] hashes to be grouped
    # @param paths [Object] path on which the hashes must be
    #   grouped
    # @return [Hash]
    def group_on_path(hashes, path)
      hashes.inject({}) do |result, hash|
        value_at_path = HashOp::Deep.fetch(hash, path)
        result[value_at_path] ||= []
        result[value_at_path] << hash
        result
      end
    end
    module_function :group_on_path

    # @param hashes [Array] hashes to be grouped
    # @param paths [Array] paths on which the hashes must be
    #   grouped, by order of grouping (1st group-level first)
    # @return [Hash]
    def group_on_paths(hashes, paths)
      return group_on_path(hashes, paths.first) if paths.length == 1

      path = paths.first
      path_groups = group_on_path(hashes, path)
      path_groups.each do |group_key, grouped_hashes|
        path_groups[group_key] = group_on_paths(grouped_hashes, paths[1..-1])
      end
    end
    module_function :group_on_paths
  end
end
