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
TODO: complete with other available operations

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rchampourlier/hash_op. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) [code of conduct](CODE_OF_CONDUCT.md).
