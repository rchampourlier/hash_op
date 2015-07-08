# HashOp


A Ruby library of functions to access and manipulate hash data structures.

[![Build Status](https://travis-ci.org/rchampourlier/hash_op.svg?branch=master)](https://travis-ci.org/rchampourlier/hash_op)
[![Code Climate](https://codeclimate.com/github/rchampourlier/hash_op/badges/gpa.svg)](https://codeclimate.com/github/rchampourlier/hash_op)
[![Coverage Status](https://coveralls.io/repos/rchampourlier/hash_op/badge.svg)](https://coveralls.io/r/rchampourlier/hash_op)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hash_op'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hash_op

## Usage

## Available operations

_See specs for more details on each operation._

### Deep Access

```ruby
HashOp::DeepAccess.fetch({a: {b: {c: 1}}}, :'a.b.c')
=> 1

HashOp::DeepAccess.merge({ a: { b: { c: 1 } } }, :'a.b.c', 2)
=> {
  :a => {
    :b => {
      :c => 2
    }
  }
}
```

### Filter

```ruby
hashes = [
  { value: 123, regexp: "itsamatch", proc: "1+1" },
  { value: 123, regexp: "abcdef", proc: "1+2" },
  { value: 234, regexp: "abcdef", proc: "1+2" }
]
criteria = {
  path: :value,
  matching_object: 123
}
HashOp::Filter.filter(hashes, { value: 123 })
=> [
  [0] {
      :proc => "1+1",
    :regexp => "itsamatch",
     :value => 123
  },
  [1] {
      :proc => "1+2",
    :regexp => "abcdef",
     :value => 123
  }
]
HashOp::Filter.filter(hashes, { value: 123, regexp: /match/ })
=> [
  [0] {
      :proc => "1+1",
    :regexp => "itsamatch",
     :value => 123
  }
]
HashOp::Filter.filter(hashes, { proc: ->(x) { eval(x) == 2 } })
=> [
  [0] {
      :proc => "1+1",
    :regexp => "itsamatch",
     :value => 123
  }
]

Internally, `HashOp::Filter::filter` uses 
`HashOp::Filter::match?(hash, criteria)` which you can
use too.
```

### Mapping

```ruby
hash = {a: { b: { c: 1 } } }
mapping = { r: { path: :'a.b.c' } }
HashOp::Mapping.apply_mapping(hash, mapping)
=> {
  :r => 1
}

hash = {
  raw: { deep: 'raw_value' },
  time: '2015-07-06 03:37:13 +0200',
  mapped_hash: {
    raw: { deep: 'deep_raw_value' },
    time: '2014-07-06 03:37:13 +0200'
  },
  parseable_string: 'a=1;b=2;t=2013-07-06 03:37:13 +0200',
  array: [
    '2015-07-06 03:37:13 +0200',
    '2014-07-06 03:37:13 +0200',
    '2013-07-06 03:37:13 +0200'
  ]
}
mapping = {
  raw: { path: :'raw.deep' },
  time: { path: :time, type: :time },
  raw_from_mapped_hash: {
    path: :'mapped_hash.raw.deep',
  },
  time_from_mapped_hash: {
    path: :'mapped_hash.time',
    type: :time
  },
  values_from_parseable_string: {
    path: :parseable_string,
    type: :parseable_string,
    parsing_mapping: {
      value: { regexp: 'a=(\d)+;' },
      time: {
        regexp: 't=(.*)$',
        type: :time
      }
    }
  },
  times_from_array: {
    type: :array,
    path: :array,
    item_mapping: { type: :time }
  }
}
HashOp::Mapping.apply_mapping(hash, mapping)
=> {
                           :raw => "raw_value",
          :raw_from_mapped_hash => "deep_raw_value",
                          :time => 2015-07-06 03:37:13 +0200,
         :time_from_mapped_hash => 2014-07-06 03:37:13 +0200,
              :times_from_array => [
    [0] 2015-07-06 03:37:13 +0200,
    [1] 2014-07-06 03:37:13 +0200,
    [2] 2013-07-06 03:37:13 +0200
  ],
  :values_from_parseable_string => {
     :time => 2013-07-06 03:37:13 +0200,
    :value => "1"
  }
}
```

TODO: complete with other available operations

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rchampourlier/hash_op. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) [code of conduct](CODE_OF_CONDUCT.md).
