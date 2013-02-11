# Moby

A module to make pure DCI available in Ruby

## Installation

Add this line to your application's Gemfile:

    gem 'Moby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install Moby

## Usage

See the examples for detailed information on how to use Moby.

Essentially you can define a context by using

Context::define :context_name do
   role :role_name do
      print_self do |x| #notice no symbol
         p "#{role_name} #use role_name to refer to the role of said name
      end
   end
end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

