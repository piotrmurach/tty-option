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
    * [2.5.2 default](#252-default)
    * [2.5.3 convert](#253-convert)

## 1. Usage

```ruby
class Command
  include TTY::Option
end
```

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

Then parsing:

```ruby
cmd.parse(%w[foo=1 foo=2])
```

Will give the following:

```ruby
cmd.params[:foo]
# => [1, 2]
```

To match any number of times use `:any`, `-1`, or `zero_or_more`:

```ruby
argument :foo do
  arity zero_or_more
end
```

To match at at least one time use `one_or_more`:

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

#### 2.5.2 default

#### 2.5.3 convert

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
cmd.parse(%w[--foo t,f,t --bar a:1 b:2 c:3])
```

Will give:

```ruby
cmd.params[:foo]
# => [true, false, true]
cmd.params[:bar]
# => {a:1, b:2, c:3}
````

You can also provide `proc` to define your own conversion:

```ruby
option :bar do
  long "--bar string"
  convert ->(val) { val.upcase }
end
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
