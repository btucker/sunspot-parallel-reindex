# Sunspot::Parallel::Reindex

Add support for multi-process reindexing with sunspot.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sunspot-parallel-reindex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sunspot-parallel-reindex

## Usage

Parameters are all optional, just like `rake sunspot:reindex`

    $ rake sunspot:reindex:parallel[<batch_size>, <models>, <processes>]

## Contributing

1. Fork it ( https://github.com/btucker/sunspot-parallel-reindex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks

Code heavily inspired by https://github.com/MiraitSystems/enju_trunk/
