# Arity

Logic to determine when Ruby functions can be called.

## Installation

Add `gem 'arity'` to your Gemfile.

## Usage
```ruby
function = Arity::Function.make(some_callable)
# note the use of .make versus .new
# some_callable should respond to :call
# otherwise, .make will raise an Arity::NotCallableError
# to avoid raising, pass {silent: true} to .make and it will return nil instead
```
```ruby
function.arity
# delegates to Ruby's built-in arity logic
```
```ruby
function.takes?(arg_count: 3, keywords: [:things])
# determines if the supplied method parameter structure is valid.
```
```ruby
function.runnable?('thing-1','thing-2','thing-3', things: 3)
# computes the parameter structure and delegates to .takes?
```
```ruby
function.run('thing-1','thing-2','thing-3', things: 3)
# calls .call on the callable with the supplied parameters
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fledman/arity.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

