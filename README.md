# Iruby::Gmaps

Primitive Google Maps output for IRuby

## Installation

Add this line to your application's Gemfile:

    gem 'iruby-gmaps'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iruby-gmaps

## Usage

```ruby
require iruby/gmaps.rb
points = [
  OpenStruct.new({lat: 33, lon: 54}),
  OpenStruct.new({lat: 33.1, lon: 54.1}),
]
IRuby.display Iruby::Gmaps.heatmap(points)

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
