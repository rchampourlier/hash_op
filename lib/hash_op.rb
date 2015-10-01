require 'hash_op/version'

# Namespacing module
module HashOp
end

dir = File.expand_path('../hash_op/*.rb', __FILE__)
Dir[dir].each do |f|
  require f
end
