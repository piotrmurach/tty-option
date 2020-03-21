<div align="center">
  <a href="https://piotrmurach.github.io/tty" target="_blank"><img width="130" src="https://github.com/piotrmurach/tty/raw/master/images/tty.png" alt="tty logo" /></a>
</div>

# TTY::Option

[![Gem Version](https://badge.fury.io/rb/tty-option.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-option.svg?branch=master)][travis]
[![Build status](https://ci.appveyor.com/api/projects/status/rtm3po27ouarfrhf?svg=true)][appveyor]
[![Code Climate](https://codeclimate.com/github/piotrmurach/tty-option/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-option/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-option.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/tty-option
[travis]: http://travis-ci.org/piotrmurach/tty-option
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-option
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-option
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

## Usage

```ruby
class Command
  include TTY::Option
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
