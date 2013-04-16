# Maroon

A module to make pure DCI available in Ruby

## Installation

Add this line to your application's Gemfile:

    gem 'maroon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install maroon

## Usage

See the examples for detailed information on how to use maroon.

Essentially you can define a context by using

Context::define :context_name do
   role :role_name do
      print_self do |x| #notice no symbol
         p "#{role_name} #use role_name to refer to the role of said name
      end
   end
end

## Running Tests

If you're using Bundler, run `bundle install` to setup your environment.

Run `rake test` or just `rake` to make the tests run.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes to the files in base.
4. Make sure you can run the default rake task with no errors _twice_
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request


Known bugs
There are a few known bugs. The two major once are that #{...} syntax in strings can't beused. This is due to
limitaion/bug in the current version of sourcify.
If declaring several role methods for the same role sourcify might get confused and return the same sexp for
multiple of them. The work around is to use do...end for the role ans {|| } for the role methods

