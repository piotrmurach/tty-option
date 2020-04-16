<div align="center">
  <a href="https://piotrmurach.github.io/tty" target="_blank"><img width="130" src="https://github.com/piotrmurach/tty/raw/master/images/tty.png" alt="tty logo" /></a>
</div>

# TTY::Option

[![Gem Version](https://badge.fury.io/rb/tty-option.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-option.svg?branch=master)][travis]
[![Build status](https://ci.appveyor.com/api/projects/status/gxml9ttyvgpeasy5?svg=true)][appveyor]
[![Maintainability](https://api.codeclimate.com/v1/badges/1083a2fd114d6faf5d65/maintainability)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-option/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-option.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/tty-option
[travis]: http://travis-ci.org/piotrmurach/tty-option
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-option
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-option/maintainability
[coverage]: https://coveralls.io/github/piotrmurach/tty-option
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-option

> Parser for command line arguments, keywords, options and environment variables

## Features

* Supports parsing of arguments, keywords, flags, options and environment variables
* Exposes a powerful DSL or hash-like way to specify various settings
* Flexible parsing of arguments that can handle lists and maps separated by comma or space characters
* Has a variety of conversions for basic types like integer and more complex like lists and maps

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-option'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tty-option

## Contents

* [1. Usage](#1-usage)
* [2. API](#2-api)
  * [2.1 argument](#21-argument)
  * [2.2 environment](#22-environment)
  * [2.3 keyword](#23-keyword)
  * [2.4 option](#24-option)
  * [2.5 settings](#25-settings)
    * [2.5.1 arity](#251-arity)
    * [2.5.2 convert](#252-convert)
    * [2.5.3 default](#253-default)
    * [2.5.4 permit](#254-permit)
    * [2.5.5 validate](#255-validate)

## 1. Usage

To start parsing command line parameters include `TTY::Option` module.

Now, you're ready to define parsed parameters like arguments, keywords, flags, options or environment variables.

For example, a quick demo to create a command that mixes all parameters usage:

```ruby
class Command
  include TTY::Option

  argument :action

  argument :image

  keyword :restart do
    default "no"
    permit %w[no on-failure always unless-stopped]
  end

  flag :detach do
    short "-d"
    long "--detach"
  end

  option :name do
    required
    long "--name string"
  end

  option :port do
    short "-p"
    long "--publish list"
    convert :list
  end

  env :rails_env

  def run
    puts params[:action]
    puts params[:image]
    puts params[:detach]
    puts params[:port]
    puts params[:restart]
    puts params[:name]
    puts params[:rails_env]
  end
end
```

Then create a command instance:

```ruby
cmd = Command.new
```

And provided input from the command line:

```
RAILS_ENV=production run restart=always -d -p 5000:3000 5001:8080 --name web ubuntu:16.4
```

Start parsing from `ARGV` or provide a custom array of inputs:

```ruby
cmd.parse
# or
cmd.parse(["RAILS_ENV=production", "run", "restart=always", "-d", ...])
```

And run the command to see the values:

```ruby
cmd.run
# =>
#  "run"
#  "ubuntu:16.4"
#  true
#  ["5000:3000", "5001:8080"]
#  "always"
#  "web"
#  "production"
````

The `cmd` object also has a direct access to all the parameters via `params`:

```ruby
cmd.params[:name] # => "web"
````

## 2. API

### 2.1 argument

### 2.2 environment

To parse environment variables use `environment` or `env` methods. By default, a parameter name will match a variable with the same name. For example, specifying a variable port:

```ruby
env :port
```

And then given a `PORT=333` on the command line, the resulting parameter would be:

```
params[:port]
# => "333"
````

To change the variable name to something else use `var` or `variable` helper:

```ruby
env :ssl do
  var "FORCE_SSL"
end
```

And then given a `FORCE_SSL=true` on the command line would result in:

```ruby
params[:ssl]
# => "true"
```

### 2.3 keyword

### 2.4 option

### 2.5 settings

#### 2.5.1 arity

To describe how many times a given parameter may appear in the command line use the `arity` method. By default every parameter is assumed to appear only once. Any other occurrence will be disregarded and included in the remaining parameters list.

For example, to match argument exactly 2 times do:

```ruby
argument :foo do
  arity 2
end
````

Then parsing from the command line:

```ruby
bar baz
```

Will give the following:

```ruby
params[:foo] # => ["bar", "baz"]
```

For parameters that expect a value, specifying arity will collect all the values matching arity requirement. For example, matching keywords:

```ruby
keyword :foo do
  arity 3
end
```

And then parsing the following:

```
foo=1 foo=2 foo=3
```

Will produce:

```ruby
params[:foo] # => ["1", "2", "3"]
```

To match any number of times use `:any`, `-1`, or `zero_or_more`:

```ruby
argument :foo do
  arity zero_or_more
end
```

To match at at least one time use `one_or_more` or `two_or_more` for many times:

```ruby
option :foo do
  arity one_or_more
  short "-b"
  long "--bar string"
end
```

You can also specify upper boundary with `at_least` helper as well:

```ruby
keyword :foo do
  arity at_least(3)
end
```

#### 2.5.2 convert

You can convert any parameter argument to another type using the `convert` method with a predefined symbol or class name. For example, to convert an argument to integer you can do:

```ruby
argument :foo do
  convert :int
end
```

The conversion types that are supported:

* `:boolean`|`:bool` - e.g. 'yes/1/y/t/' becomes `true`, 'no/0/n/f' becomes `false`
* `:date` - parses dates formats "28/03/2020", "March 28th 2020"
* `:float` - e.g. `-1` becomes `-1.0`
* `:int`|`:integer` - e.g. `+1` becomes `1`
* `:path`|`:pathname` - converts to `Pathname` object
* `:regexp` - e.g. "foo|bar" becomes `/foo|bar/`
* `:uri` - converts to `URI` object
* `:sym`|`:symbol` - e.g. "foo" becomes `:foo`
* `:list`|`:array` - e.g. 'a,b,c' becomes `["a", "b", "c"]`
* `:map`|`:hash` - e.g. 'a:1 b:2 c:3' becomes `{a: "1", b: "2", c: "3"}`

In addition you can specify a plural or append `list` to any base type:

* `:ints` or `:int_list` - will convert to a list of integers
* `:floats` or `:float_list` - will convert to a list of floats
* `:bools` or `:bool_list` - will convert to a list of booleans, e.g. 't,f,t' becomes `[true, false, true]`

Similarly, you can append `map` to any base type:

* `:int_map` - will convert to a map of integers, e.g 'a:1 b:2 c:3' becomes `{a: 1, b: 2, c: 3}`
* `:bool_map` - will convert to a map of booleans, e.g 'a:t b:f c:t' becomes `{a: true, b: false, c: true}`

For example, to parse options with required list and map arguments:

```ruby
option :foo do
  long "--foo map"
  convert :bools
end

option :bar do
  long "--bar int map"
  convert :int_map
end
````

And then parsing the following:

```ruby
--foo t,f,t --bar a:1 b:2 c:3
```

Will give:

```ruby
params[:foo]
# => [true, false, true]
params[:bar]
# => {a:1, b:2, c:3}
````

You can also provide `proc` to define your own conversion:

```ruby
option :bar do
  long "--bar string"
  convert ->(val) { val.upcase }
end
```

#### 2.5.3 default

#### 2.5.4 permit

The `permit` setting allows you to restrict an input to a set of possible values:

```ruby
option :foo do
  long "--foo string"
  permit ["bar", "baz"]
end
```

And then parsing

```
--foo bar
```

Will populate parameters value:

```ruby
params[:foo] # => "bar"
```

Attempting to parse not permitted value will raise an error:

```
--foo qux
# raises TTY::Option::UnpermitedArgument
```

Permitted values are checked after applying conversion:

```ruby
option :foo do
  long "--foo int"
  confert :int
  permit [11, 12, 13]
end
```

Then parsing:

```
--foo 14
# raises TTY::Option::UnpermittedArgument
```

#### 2.5.5 validate

Use the `validate` setting if you wish to ensure only valid inputs are allowed.

You can use a string or regular expression to describe your validation rule:

```ruby
option :foo do
  long "--foo VAL"
  validate "\d+"
end
```

Then parsing:

```
--foo bar
# raises TTY::Option:InvalidArgument
```

You can also express a validation rule with a `proc` object:

```ruby
keyword :foo do
  arity one_or_more
  convert :int
  validate ->(val) { val < 12 }
end
```

Then parsing:

```
foo=11 foo=13
# raises TTY::Option::InvalidArgument
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/tty-option. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/piotrmurach/tty-option/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TTY::Option project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/tty-option/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2020 Piotr Murach. See LICENSE for further details.
