<div align="center">
  <a href="https://ttytoolkit.org"><img width="130" src="https://github.com/piotrmurach/tty/raw/master/images/tty.png" alt="TTY Toolkit logo"/></a>
</div>

# TTY::Option

[![Gem Version](https://badge.fury.io/rb/tty-option.svg)][gem]
[![Actions CI](https://github.com/piotrmurach/tty-option/workflows/CI/badge.svg?branch=master)][gh_actions_ci]
[![Build status](https://ci.appveyor.com/api/projects/status/gxml9ttyvgpeasy5?svg=true)][appveyor]
[![Maintainability](https://api.codeclimate.com/v1/badges/1083a2fd114d6faf5d65/maintainability)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-option/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-option.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/tty-option
[gh_actions_ci]: https://github.com/piotrmurach/tty-option/actions?query=workflow%3ACI
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-option
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-option/maintainability
[coverage]: https://coveralls.io/github/piotrmurach/tty-option
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-option

> Parser for command line arguments, keywords, options and environment variables

## Features

* Support for parsing of **positional arguments**, **keyword arguments**, **flags**, **options** and **environment variables**.
* A convenient way to declare parsed parameters via **DSL** with a fallback to **hash-like syntax**.
* Flexible parsing that **doesn't force any order for the parameters**.
* Handling of complex option and keyword argument inputs like **lists** and **maps**.
* Many **conversions types** provided out of the box, from basic integer to more complex hash structures.
* Automatic **help generation** that can be customised with **usage** helpers like banner, examples and more.
* Parsing **doesn't raise errors** by default and collects issues to allow for better user experience. 
* Ability to declare **global options** with inheritance that copies parameters to a child class.

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
  * [2.2 keyword](#22-keyword)
  * [2.3 option](#23-option)
  * [2.4 environment](#24-environment)
  * [2.5 parameter settings](#25-parameter-settings)
    * [2.5.1 arity](#251-arity)
    * [2.5.2 convert](#252-convert)
    * [2.5.3 default](#253-default)
    * [2.5.4 description](#254-description)
    * [2.5.5 hidden](#255-hidden)
    * [2.5.6 name](#256-name)
    * [2.5.7 optional](#257-optional)
    * [2.5.8 permit](#258-permit)
    * [2.5.9 required](#259-required)
    * [2.5.10 validate](#2510-validate)
  * [2.6 parse](#26-parse)
    * [2.6.1 :raise_on_parse_error](#261-raise_on_parse_error)
    * [2.6.2 :check_invalid_params](#262-check_invalid_params)
  * [2.7 params](#27-params)
    * [2.7.1 errors](#271-errors)
    * [2.7.2 remaining](#272-remaining)
    * [2.7.3 valid?](#273-valid?)
  * [2.8 usage](#28-usage)
    * [2.8.1 header](#281-header)
    * [2.8.2 program](#282-program)
    * [2.8.3 command](#283-command)
    * [2.8.4 banner](#284-banner)
    * [2.8.5 description](#285-description)
    * [2.8.6 example](#286-examples)
    * [2.8.7 footer](#287-footer)
  * [2.9 help](#29-help)
    * [2.9.1 sections](#291-sections)
    * [2.9.2 :indent](#292-indent)
    * [2.9.3 :order](#293-order)
    * [2.9.4 :param_display](#294-param_display)
    * [2.9.5 :width](#295-width)

## 1. Usage

To start parsing command line parameters include `TTY::Option` module.

Now, you're ready to define parsed parameters like arguments, keywords, flags, options or environment variables.

For example, a quick demo to create a command that mixes all parameters usage:

```ruby
class Command
  include TTY::Option

  usage do
    program "dock"

    command "run"

    desc "Run a command in a new container"

    example "Set working directory (-w)",
            "  $ dock run -w /path/to/dir/ ubuntu pwd"

    example <<~EOS
    Mount volume
      $ dock run -v `pwd`:`pwd` -w `pwd` ubuntu pwd
    EOS
  end

  argument :image do
    required
    desc "The name of the image to use"
  end

  argument :command do
    optional
    desc "The command to run inside the image"
  end

  keyword :restart do
    default "no"
    permit %w[no on-failure always unless-stopped]
    desc "Restart policy to apply when a container exits"
  end

  flag :help do
    short "-h"
    long "--help"
    desc "Print usage"
  end

  flag :detach do
    short "-d"
    long "--detach"
    desc "Run container in background and print container ID"
  end

  option :name do
    required
    long "--name string"
    desc "Assign a name to the container"
  end

  option :port do
    arity one_or_more
    short "-p"
    long "--publish list"
    convert :list
    desc "Publish a container's port(s) to the host"
  end

  def run
    if params[:help]
      print help
      exit
    else
      pp params.to_h
    end
  end
end
```

Then create a command instance:

```ruby
cmd = Command.new
```

And provided input from the command line:

```
restart=always -d -p 5000:3000 5001:8080 --name web ubuntu:16.4 bash
```

Start parsing from `ARGV` or provide a custom array of inputs:

```ruby
cmd.parse
# or
cmd.parse(%w[restart=always -d -p 5000:3000 5001:8080 --name web ubuntu:16.4 bash])
```

And run the command to see the values:

```ruby
cmd.run
# =>
# {:help=>false,
#  :detach=>true,
#  :port=>["5000:3000", "5001:8080"],
#  :name=>"web",
#  :restart=>"always",
#  :image=>"ubuntu:16.4",
#  :command=>"bash"}
````

The `cmd` object also has a direct access to all the parameters via the `params`:

```ruby
cmd.params[:name]     # => "web"
cmd.params["command"] # => "bash
````

And when `--help` is found on the command line the run will print help:

```ruby
cmd.run
```

To print help information to the terminal use `help` method:

```ruby
print cmd.help
```

This will result in the following output:

```
Usage: dock run [OPTIONS] IMAGE [COMMAND] [RESTART=RESTART]

Run a command in a new container

Arguments:
  IMAGE    The name of the image to use
  COMMAND  The command to run inside the image

Keywords:
  RESTART=RESTART  Restart policy to apply when a container exits (permitted:
                   no, on-failure, always, unless-stopped) (default "no")

Options:
  -d, --detach        Run container in background and print container ID
  -h, --help          Print usage
      --name string   Assign a name to the container
  -p, --publish list  Publish a container's port(s) to the host

Examples:
  Set working directory (-w)
    $ dock run -w /path/to/dir/ ubuntu pwd

  Mount volume
    $ dock run -v `pwd`:`pwd` -w `pwd` ubuntu pwd
```

## 2. API

### 2.1 argument

You can parse positional arguments with the `argument` method. To declare an argument you need to provide a name for the access key in the `params` like so:

```ruby
argument :foo
```

Then parsing command line input:

```
11 12 13
```

Would result only in one argument parsed and the remaining ignored:

```ruby
params[:foo] # => "11"
```

A more involved example to parse multiple positional arguments requires use of helper methods:

```ruby
argument :foo do
  required                   # a default
  variable "foo(int)"        # name for the usage display
  arity one_or_more          # how many times to occur
  convert :int               # values converted to integer
  validate -> { |v| v < 14 } # validation rule
  desc "Some foo desc"       # description for the usage display
end
```

Parsing the previous input:

```bash
11 12 13
```

Would result in all values being collected and converted to integers:

```ruby
params[:foo] # => [11,12,13]
```

The previous argument definition can also be written using hash syntax. This is especially useful if you want to specify arguments programmatically:

```ruby
argument :foo,
  required: true,
  variable: "foo(int)",
  arity: "+",
  convert: :int,
  validate: -> { |v| v < 14 },
  desc: "Some foo desc"
```

To read more about available settings see [parameter settings](#25-parameter-settings).

### 2.2 keyword

To parse keyword arguments use the `keyword` method. To declare a keyword argument you need to provide a name for the key in the `params` like so:

```ruby
keyword :foo
```

By default the keyword parameter name will be used as the keyword name on the command line:

```bash
foo=11
```

Parsing the above would result in:

```ruby
params[:foo] # => "11"
```

A more involved example to parse multiple keyword arguments requires use of helper methods:

```ruby
keyword :foo do
  required                   # by default keywrod is not required
  arity one_or_more          # how many times to occur
  convert :int               # values converted to integer
  validate -> { |v| v < 14 } # validation rule
  desc "Some foo desc"       # description for the usage display
end
```

Then provided the following command line input:

```bash
foo=11 foo=12 foo=13
```

The result would be:

```ruby
params[:foo] # => [11,12,13]
```

You can also specify for the keyword argument to accept a list type:

```ruby
keyword :foo do
  required                   # by default keyword is not required
  arity one_or_more          # how many times to occur
  convert :int_list          # input can be a list of integers
  validate -> { |v| v < 14 } # validation rule
  desc "Some foo desc"       # description for the usage display
end
```

Then command line input can contain a list as well:

```bash
foo=11 12 foo=13
```

Which will result in the same value:

```ruby
params[:foo] # => [11,12,13]
```

A keyword definition can be also a hash. This is especially useful if you intend to specify keyword arguments programmatically:

```ruby
keyword :foo,
  required: true,
  arity: :+,
  convert: :int_list,
  validate: -> { |v| v < 14 },
  desc: "Some foo desc"
```

To read more about available settings see [parameter settings](#25-parameter-settings).

### 2.3 option

To parse options and flags use the `option` or `flag` methods.

To declare an option you need to provide a name for the key used to access value in the `params`:

```ruby
option :foo
```

By default the option parameter name will be used to generate a long option name:

```
--foo=11
```

Parsing the above will result in:

```ruby
params[:foo] # => "11"
```

To specify a different name for the parsed option use the `short` and `long` helpers:

```ruby
option :foo do
  short "-f"     # declares a short flag
  long  "--foo"  # declares a long flag
end
```

If you wish for an option to accept an argument, you need to provide an extra label.

For example, for both short and long flag to require argument do:

```ruby
option :foo do
  short "-f"
  long  "--foo string"  # use any name after the flag name to specify required argument
  # or
  long  "--foo=string"  # you can also separate required argument with =
end
```

To make a long option with an optional argument do:

```ruby
option :foo do
  long "--foo [string]" # use any name within square brackets to make argument optional
end
```

A more involved example that parses a list of integer may look like this:

```ruby
option :foo do
  required                   # by default option is not required
  arity one_or_more          # how many times option can occur
  short "-f"                 # declares a short flag name
  long  "--foo list"         # declares a long flag with a required argument
  convert :int_list          # input can be a list of integers
  validate -> { |v| v < 14 } # validation rule
  desc "Some foo desc"       # description for the usage display
end
```

Given command line input:

```bash
--foo=10,11 -f 12 13
```

The resulting value will be:

```ruby
params[:foo] # => [10,11,12,13]
```

An option  definition can be declared as a hash as well. This is especially useful if you intend to specify options programmatically:

```ruby
option :foo,
  required: true,
  arity: :+,
  short: "-f",
  long: "--foo list",
  convert: :int_list,
  validate: -> { |v| v < 14 },
  desc: "Some foo desc"
```

To read more about available settings see [parameter settings](#25-parameter-settings).

### 2.4 environment

To parse environment variables use `environment` or `env` methods.

By default, a parameter name will match a environment variable with the same name. For example, specifying a variable `:foo`:

```ruby
env :foo
```

And then given the following command line input:

```
FOO=bar
```

The resulting parameter would be:

```ruby
params[:foo] # => "bar"
````

To change the variable name to something else use `var` or `variable` helper:

```ruby
env :foo do
  var "FOO_ENV"
end
```

And then given a `FOO_ENV=bar` on the command line would result in:

```ruby
params[:foo] # => "bar"
```

A more involved example that parses a list of integer may look like this:

```ruby
environment :foo do
  required                   # by default environment is not required
  arity one_or_more          # how many times env var can occur
  variable "FOO_ENV"         # the command line input name
  convert map_of(:int)       # input can be a map of integers
  validate -> { |v| v < 14 } # validation rule
  desc "Some foo desc"       # description for the usage display
end
```

Given command line input:

```bash
FOO_ENV=a:1&b:2 FOO_ENV=c=3 d=4
```

The resulting `params` would be:

```ruby
params[:foo] # => {a:1,b:2,c:3,d:4}
```

To read more about available settings see [parameter settings](#25-parameter-settings).

### 2.5 parameter settings

These settings are supported by all parameter types with the exception of `short` and `long` which are specific to options only.

#### 2.5.1 arity

To describe how many times a given parameter may appear in the command line use the `arity` setting.

By default every parameter is assumed to appear only once. Any other occurrence will be disregarded and included in the remaining parameters list.

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

To match any number of times use `:any`, `:*`, `-1`, `any` or `zero_or_more`:

```ruby
argument :foo do
  arity zero_or_more
end
```

To match at at least one time use `:+` or `one_or_more`:

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

The [help](#29-help) method will handle the arity for the display. Given the following argument definition:

```ruby
argument :foo do
  arity one_or_more
end
```

The usage banner will display:

```
Usage: foobar FOO [FOO...]
```

#### 2.5.2 convert

You can convert any parameter argument to another type using the `convert` method with a predefined symbol or class name. For example, to convert an argument to integer you can do:

```ruby
argument :foo do
  convert :int
  # or
  convert Integer
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
* `:bools` or `:bool_list` - will convert to a list of booleans, e.g. `t,f,t` becomes `[true, false, true]`

If like you can also use `list_of` helper and pass the type as a first argument.

Similarly, you can append `map` to any base type:

* `:int_map` - will convert to a map of integers, e.g `a:1 b:2 c:3` becomes `{a: 1, b: 2, c: 3}`
* `:bool_map` - will convert to a map of booleans, e.g `a:t b:f c:t` becomes `{a: true, b: false, c: true}`

For convenience and readability you can also use `map_of` helper and pass the type as a first argument.

For example, to parse options with required list and map arguments:

```ruby
option :foo do
  long "--foo map"
  convert :bools   # or `convert list_of(:bool)`
end

option :bar do
  long "--bar int map"
  convert :int_map   # or `conert map_of(:int)`
end
````

And then parsing the following:

```bash
--foo t,f,t --bar a:1 b:2 c:3
```

Will give the following:

```ruby
params[:foo]
# => [true, false, true]
params[:bar]
# => {:a=>1, :b=>2, :c=>3}
````

You can also provide `proc` to define your own custom conversion:

```ruby
option :bar do
  long "--bar string"
  convert ->(val) { val.upcase }
end
```

#### 2.5.3 default

Any optional parameter such as options, flag, keyword or environment variable, can have a default value. This value can be specified with the `default` setting and will be used when the command-line input doesn't match any parameter definitions.

For example, given the following option definition:

```ruby
option :foo do
  long "--foo string"
  default "bar"
end
```

When no option `--foo` is parsed, then the `params` will be populated:

```ruby
params[:foo] # => "bar"
```

The default can also be specified with a `proc` object:

```ruby
option :foo do
  long "--foo string"
  default -> { "bar" }
end
```

A parameter cannot be both required and have default value. Specifying both will raise `ConfigurationError`. For example, all positional arguments are required by default. If you want to have a default for a required argument make it `optional`:

```ruby
argument :foo do
  optional
  default "bar"
  desc "Some description"
end
```

The default will be automatically displayed in the usage information:

```
Usage: foobar [OPTIONS] [FOO]

Arguments:
  FOO  Some description (default "bar")
```

#### 2.5.4 desc(ription)

To provide a synopsis for a parameter use the `description` or shorter `desc` setting. This information is used by the [help](#29-help) method to produce usage information:

```ruby
option :foo do
  desc "Some description"
end
```

The above will result in:

```
Usage: foobar [OPTIONS]

Options:
  --foo  Some description
```

#### 2.5.5 hidden

To hide a parameter from display in the usage information use the `hidden` setting:

```ruby
argument :foo

argument :bar do
  hidden
end
```

The above will hide the `:bar` parameter from the usage:

```
Usage: foobar FOO
```

#### 2.5.6 name

By default the parameter key will be used to match command-line input arguments.

This means that a key `:foo_bar` will match `"foo-bar"` parameter name. For example, given a keyword:

```ruby
keyword :foo_bar
```

And then command-line input:

```
foo-bar=baz
```

The parsed result will be:

```ruby
params[:foo_bar] # => "baz"
```

To change the parameter name to a custom one, use the `name` setting:

```ruby
keywor :foo_bar do
  name "fum"
end
```

Then parsing:

```
fum=baz
```

Will result in:

```
params[:foo] # => "baz"
````

For environment variables use the upper case when changing name:

```ruby
env :foo do
  name "FOO_VAR"
end
```

#### 2.5.7 optional

Apart from the positional argument, all other parameters are optional. To mark an argument as optional use similar naming `optional` setting:

```ruby
argument :foo do
  desc "Foo arg description"
end

argument :bar do
  optional
  desc "Bar arg description"
end
```

The optional argument will be surrounded by brackets in the usage display:

```
Usage: foobar [OPTIONS] FOO [BAR]

Arguments:
  FOO  Foo arg description
  BAR  Bar arg description
```

#### 2.5.8 permit

The `permit` setting allows you to restrict an input to a set of possible values.

For example, let's restrict option to only `"bar"` and `"baz"` strings:

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

Attempting to parse not permitted value:

```
--foo qux
```

Will internally produce a `TTY::Option::UnpermittedArgument` error and make the `params` invalid.

Permitted values are checked after applying conversion. Because of this, you need to provide the expected type for the `permit` setting:

```ruby
option :foo do
  long "--foo int"
  confert :int
  permit [11, 12, 13]
end
```

Then parsing an unpermitted value:

```
--foo 14
```

Will invalidate `params` and collect the `TTY::Option::UnpermittedArgument` error.

The permitted values are automatically appended to the parameter synopsis when displayed in the usage information. For example, given an option:

```ruby
option :foo do
  short "-f"
  long "--foo string"
  permit %w[a b c d]
  desc "Some description"
end
```

Then the usage information for the option would be:

```
Usage: foobar [OPTIONS]

Options:
  -f, --foo string  Some description (permitted: a,b,c,d)
```

#### 2.5.9 required

Only arguments are required. Any other parameters like options, keywords and environment variables are optional. To force parameter presence in input use `required` setting.

```ruby
keyword :foo do
  required
  desc "Foo keyword description"
end

keyword :bar do
  desc "Bar keyword description"
end
```

Because `foo` keyword is required it won't have brackets around the parameter in the usage display:

```
Usage: foobar FOO=FOO [BAR=BAR]

Keywords:
  FOO=FOO  Foo keyword description
  BAR=BAR  Bar keyword description
```

Note: Using required options is rather discouraged as these are typically expected to be optional.

#### 2.5.10 validate

Use the `validate` setting if you wish to ensure only inputs matching filter criteria are allowed.

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
```

Will internally cause an exception `TTY::Option::InvalidArgument` that will make `params` invalid.

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
```

Will similarly collect the `TTY::Option::InvalidArgument` error and render `params` invalid.

### 2.6 parse

After all parameters are defined, use the `parse` to process command line inputs.

By default the `parse` method takes the input from the `ARGV` and the `ENV` variables.

Alternatively, you can call `parse` with custom inputs. This is especially useful for testing your commands.

Given parameter definitions:

```ruby
argument :foo

flag :bar

keyword :baz

env :qux
```

Then parsing the following inputs:

```ruby
parse(%w[12 --bar baz=a QUX=b])
```

Would populate parameters:

```ruby
params[:foo] # => "12"
params[:bar] # => true
params[:baz] # => "a"
params[:qux] # => "b"
```

The parsing is flexible and doesn't force any order for the parameters. Options can be inserted anywhere between positional or keyword arguments.

It handles parsing of compacted shorthand options that start with a single dash. These need to be boolean options bar the last one that can accept argument. All these are valid:

```
-f
-fbq
-fbqs 12  # mixed with an argument
```

Parameter parsing stops after the `--` terminator is found. The leftover inputs are collected and accessible via the `remaining` method.

#### 2.6.1 :raise_on_parse_error

By default no parse errors are raised. Why? Users do not appreciate Ruby errors in their terminal output. Instead, parsing errors are made accessible on the `params` object with the [errors](#271-errors) method.

However, if you prefer to handle parsing errors yourself, you can do so with `:raise_on_parse_error` keyword:

```ruby
parse(raise_on_parse_error: true)
```

Then in your code you may want to surround your `parse` call with a rescue clause:

```ruby
begin
  parse(raise_on_parse_error: true)
rescue TTY::Option::ParseError => err
  # do something here
end
```

#### 2.6.2 :check_invalid_params

Users can provide any input, including parameters you didn't expect and define.

By default, when unknown parameter is found in the input, an `TTY::Option::InvalidParameter` error will be raised internally and collected in the `errors` list.

If, on the other hand, you want to ignore unknown parameters and instead leave them alone during the parsing use the `:check_invalid_params` option like so:

```ruby
parse(check_invalid_params: false)
```

This way all the unrecognized parameters will be collected into a [remaining](#272-remaining) list accessible on the `params` instance.

### 2.7 params

Once all parameters are defined, they are accessible via the `params` instance method.

The `params` behaves like a hash with an indifferent access. It doesn't distinguish between arguments, keywords or options. Each parameter needs to have a unique identifier.

For example, given a command with all parameter definitions:

```ruby
class Command
  include TTY::Option

  argument :foo

  keyword :bar

  option :baz

  env :qux

  def run
    print params[:foo]
    print params["bar"]
    print params["baz"]
    print params[:qux]
  end
end
```

Then parsing the command:

```ruby
cmd = Command.new
cmd.parse
```

With the command-line input:

```
a bar=b --baz c QUX=d
```

And running the command:

```ruby
cmd.run
```

Will output:

```
abcd
```

#### 2.7.1 errors

Only configuration errors are raised. The parsing errors are not raised by default. Instead any parse error is made available via the `errors` method on the `params` object:

```ruby
params.errors
# => AggregateErors
````

The returned `AggregateErrors` object is an `Enumerable` that allows you to iterate over all of the errors.

It has also a convenience methods like:

* `messages` - access all error messages as an array
* `summary` - a string of nicely formatted error messages ready to display in terminal

For example, let's say we have an argument definition that requires at least 2 occurrences on the command line:

```ruby
argument :foo do
  arity at_least(2)
end
```

And only one argument is provided in the input. Then output summary:

```ruby
puts params.errors.summary
````

Would result in the following being printed:

```
Error: argument 'foo' should appear at least 2 times but appeared 1 time
```

Let's change the previous example and add conversion to the mix:

```ruby
argument :foo do
  arity at_least(2)
  convert :int
end
````

And provided only one argument string "zzz", the summary would be:

```
Errors:
  1) Argument 'foo' should appear at least 2 times but appeared 1 time
  2) Cannot convert value of `zzz` into 'int' type for 'foo' argument
```

If, on the other hand, you prefer to raise errors, you can do so using the `:raise_on_parse_error` keyword:

```ruby
parse(raise_on_parse_error: true)
```

This way any attempt at parsing invalid input will raise to the terminal.

#### 2.7.2 remaining

Users can provide any input, including parameters you didn't expect and define.

By default, when unknown parameter is found in the input, an `TTY::Option::InvalidParameter` error will be raised internally and collected in the `errors` list.

If, on the other hand, you want to ignore unknown parameters and instead leave them alone during the parsing use the `:check_invalid_params` option like so:

```ruby
parse(check_invalid_params: true)
```

This way all the unrecognized parameters will be collected into a list. You can access them on the `params` instance with the `remaining` method.

For example, let's assume that user provided `--unknown` option that we didn't expect. Inspecting the `remaining` parameters, we would get:

```ruby
params.remaining # => ["--unknown"]
```

Any parameters after the `--` terminator will be left alone during the parsing process and collected into the `remaining` list. This is useful in situations when you want to pass parameters over to another command-line applications.

#### 2.7.3 valid?

Once parsing of the command-line input is done, you can check if all the conditions defined by the parameters are met with the `valid?` method.

```ruby
params.valid?
```

You can use this to decide how to deal with parsing errors and what exit status to use.

For example, you can decide to implement a command method like this:

```ruby
if params.valid?
  # ... process params
else
  puts params.errors.summary
  exit
end
```

You can combine errors reporting with existing with the [tty-exit](https://github.com/piotrmurach/tty-exit) module.

The `TTY::Exit` module exposes the `exit_with` method and can be used like this:

```ruby
class Command
  include TTY::Exit
  include TTY::Option

  def run
    if params.valid?
      # ... process params
    else
      exit_with(:usage_error, params.errors.summary)
    end
  end
end
```

### 2.8 usage

The `usage` and its helper methods allow you to configure the `help` display to your liking. The `header`, `desc(ription)`, `example` and `footer` can be called many times. Each new call will create a new paragraph. If you wish to insert multiple lines inside a given paragraph separate arguments with a comma.

#### 2.8.1 header

To provide information above the banner explaining how to execute a program, use the `header` helper.

```ruby
usage do
  header "A command-line interface for foo service"
end
```

Further, you can add more paragraphs as comma-separated arguments to `header` with an empty string to represent a new line:

```ruby
usage do
  header "A command-line interface for foo service",
         "",
         "Access and retrieve data from foo service"
end
```

Alternatively, you can add paragraphs calling `header` multiple times:

```ruby
usage do
  header "A command-line interface for foo service"

  header "Access and retrieve data from foo service"
end
```

#### 2.8.2 program

By default the program name is inferred for you from the executable file name.

You can override the default name using the `program` helper.

```ruby
usage do
  program "custom-name"
end
````

Then the program name will be used in the banner:

```bash
Usage: custom-name
```

#### 2.8.3 command

By default the command name is inferred from the class name.

For example, based on the following:

```ruby
class NetworkCreate
  include TTY::Option
end
```

The command name will become `network-create`. To change this use the `command` and `commands` helpers:

```ruby
class NetworkCreate
  include TTY::Option

  usage do
    commands "network", "create"
  end
end
````

This will result in the following usage information:

```
Usage: program network create
```

If you don't wish to infer the command name use the `no_command` method:

```ruby
usage do
  no_command
end
````

#### 2.8.4 banner

The usage information of how to use a program is displayed right after header. If no header is specified, it will be displayed first.

This information is handled by the `banner` helper. By default, it will use the parameter definitions to generate usage information.

For example, given the following declarations:

```ruby
usage do
  program :foo

  command :bar
end

argument :baz

keyword :qux do
  convert :uri
end

option :fum
```

The generated usage information will be:

```bash
Usage: foo bar [OPTIONS] BAZ [QUX=URI]
```

If you want to configure how arguments are displayed specify [2.8.2 :param_display](#282-param_display) setting.

You can also change completely how to the banner is displayed:

```ruby
usage do
  program "foo"

  banner "Usage: #{program} BAR BAZ"
end
```

#### 2.8.5 desc(ription)

The description is placed between usage information and the parameters and given with `desc` or `description` helpers.

The `desc` helper accepts multiple strings that will be displayed on separate lines.

```ruby
usage do
  desc "Some description", "on multiline"
end
```

This will result in the following help output:

```
Some description
on multiline
```

The `desc` helper can be called multiple times to build an examples section:

```ruby
usage do
  desc "Some description", "on multiline"

  desc <<~EOS
  Another description
  on multiline
  EOS
end
```

#### 2.8.6 example(s)

To add usage examples section to the help information use the `example` or `examples` methods.

The `example` helper accepts multiple strings that will be displayed on separate lines. For instance, the following class will add a single example:

```ruby
usage do
  example "Some example how to use foo",
          " $ foo bar"
end
```

This will result in the following help output:

```
Examples:
  Some example how to use foo
    $ foo bar
```

The `example` helper can be called multiple times to build an examples section:

```ruby
usage do
  example "Some example how to use foo",
          " $ foo bar"

  example <<~EOS
  Another example how to use foo"
    $ foo baz
  EOS
end
```

The usage help will contain the following:

```
Examples:
  Some example how to use foo
    $ foo bar

  Another example how to use foo
    $ foo baz
```

#### 2.8.7 footer

To provide information after all information in the usage help, use the `footer` helper.

```ruby
usage do
  footer "Run a command followed by --help to see more info"
end
```

Further, you can add more paragraphs as comma-separated arguments to `footer` with an empty string to represent a new line:

```ruby
usage do
  footer "Run a command followed by --help to see more info",
         "",
         "Options marked with (...) can be given more than once"
end
```

Alternatively, you can add paragraphs calling `footer` multiple times:

```ruby
usage do
  footer "Run a command followed by --help to see more info"

  footer "Options marked with (...) can be given more than once"
end
```

### 2.9 help

With the `help` instance method you can generate usage information from the defined parameters and the usage. The [usage](#28-usage) describes how to add different sections to the help display.

Let's assume you have the following command with a run method that prints help:


```ruby
class Command
  include TTY::Option

  usage do
    program "foobar",
    header  "foobar CLI"
    desc    "Some foobar description"
    example "Some example"
    footer  "Run --help to see more info"
  end

  argument :bar, desc: "Some argument description"
  keyword :baz, desc: "Some keyword description"
  env :fum, desc: "Some env description"

  flag :help do
    short "-h"
    long  "--help"
    desc "Print usage"
  end

  def run
    if params[:help]
      print help
      exit
    end
  end
end
```

Running the command with `--help` flag:

```ruby
cmd = Command.new
cmd.parse(%w[--help])
cmd.run
```

Will produce:

```
foobar CLI

Usage: foobar [OPTIONS] [ENVIRONMENT] BAR [BAZ=BAZ]

Some foobar description

Arguments:
  BAR  Some argument description

Keywords:
  BAZ=BAZ  Some keyword description

Options:
  -h, --help Print usage

Envrionment:
  FUM  Some env description

Examples:
  Some example

Run --help to see more info
```

#### 2.9.1 sections

It is possible to change the usage content by passing a block to `help`. The `help` method yields an object that contains all the sections and provides a hash-like access to each of its sections.

The following are the names for all supported sections:

* `:header`
* `:banner`
* `:description`
* `:arguments`
* `:keywords`
* `:options`
* `:environments`
* `:exmaples`
* `:footer`

You can use `add_before`, `add_after`, `delete` and `replace` to modify currently existing sections or add new ones.

For example, to remove a header section do:

```ruby
help do |sections|
  sections.delete :header
end
```

To insert a new section after `:arguments` called `:commands` do:

```ruby
help do |sections|
  sections.add_after :arguments, :commands,
                     "\nCommands:\n  create  A command description"
end
```

To replace a section's content use `replace`:

```ruby
help do |sections|
  sections.replace :footer, "\nGoodbye"
end
```

#### 2.9.2 :indent

By default has not indentation for any of the sections bar parameters.

To change the indentation for the entire usage information use `:indent` keyword:

```ruby
help(indent: 2)
```

#### 2.9.3 :order

All parameters are alphabetically ordered in their respective sections. To change this default behaviour use the `:order` keyword when invoking `help`.

The `:order` expects a `Proc` object. For example, to remove any ordering and preserve the parameter declaration order do:

```ruby
help(order: ->(params) { params })
````

#### 2.9.4 :param_display

By default banner positional and keyword arguments are displayed with all letters uppercased.

For example, given the following parameter declarations:

```ruby
program "run"

argument :foo

keyword :bar do
  required
  convert :uri
end

option :baz
```

The banner output would be as follows:

```bash
Usage: run [OPTIONS] FOO BAR=URI
```

To change the banner parameter display use `:param_display` keyword.

For example, to lowercase and surround your parameters with `< >` brackets do:

```ruby
help(param_display: ->(str) { "<#{str.downcase}>" })
```

This will produce the following output:

```
Usage: run [<options>] <foo> <bar>=<uri>
```

#### 2.9.5 :width

By default the help information is wrapped at `80` columns. If this is not what you want you can change it with `:width` keyword.

For example, to change the help to always take up all the terminal columns consider using [tty-screen](https://github.com/piotrmurach/tty-screen):

```ruby
help(width: TTY::Screen.width)
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
