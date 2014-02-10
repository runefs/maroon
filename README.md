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

```ruby
Context.define :context_name do
   role :role_name do
      print_self do |x| #notice no symbol
         p "#{role_name} #use role_name to refer to the role of said name
      end
   end
end
```

## Running Tests

If you're using Bundler, run `bundle install` to setup your environment.

Run `rake default` or just `rake` to make the tests run.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes to the files in base.
4. Make sure you can run the default rake task with no errors _twice_
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

All changes should be done to the code in the base folder or the test folder.
The code in the base folder is the implementation of maroon. When the default rake task is executed code will be generated
in the 'generated' folder. The code in generated will be used when running the tests.
If all tests pass
1. Copy the generated files from 'generated' to 'lib'
2. Rerun the the default rake task
3. If all tests pass copy the generated file from 'generated' to 'lib'
4. commit and create a pull request

There's a rake task (build_lib) that will do the above if you are courageous enough to potentially loose your changes.

Known bugs
1. There are a few known bugs. The two major once are that double quotes can't be used. This is due to
limitation/bug in the current version of sourcify.
2. Using 'self' in a role method points to the context itself where it should be the role player



Short description of the flow
The class named Context (defined in maroon_base.rb) will read and parse the block passed to the Context.define method
When the parsing is complete each method will be represented by an AST (using S-expressions). The transformer context
will take over from this point. In time it runs through the definition of all roles (including there methods) and interactions.
For each method it will use the AstRewritter context to rewrite the methods (e.g. call the correct method on the context
object when a role method is called). The AstRewritter is build on another context namely the AbstractSyntaxTree that is used to represent
and semantics to the abstract syntax tree (S-expressions) that represents each method.
When all methods have been rewritten the transformer will either write the corresponding class definition to file (if so specified)
or create a class in memory.
