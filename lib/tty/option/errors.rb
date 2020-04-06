# frozen_string_literal: true

module TTY
  module Option
    Error = Class.new(StandardError)

    # Raised when an option matches more than one parameter option
    AmbiguousOption = Class.new(Error)

    # Raised when overriding already defined conversion
    ConversionAlreadyDefined = Class.new(Error)

    # Raised when argument doesn't match expected value
    InvalidArgument = Class.new(Error)

    # Raised when number of arguments doesn't match
    InvalidArity = Class.new(Error)

    # Raised when conversion provided with unexpected argument
    InvalidConversionArgument = Class.new(Error)

    # Raised when found unrecognized option
    InvalidOption = Class.new(Error)

    # Raised when permitted type is incorrect
    InvalidPermitted = Class.new(Error)

    # Raised when validation format is not supported
    InvalidValidation = Class.new(Error)

    # Raised when option requires an argument
    MissingArgument = Class.new(Error)

    # Raised when a parameter is required but not present
    MissingParameter = Class.new(Error)

    # Raised when attempting to register already registered parameter
    ParameterConflict = Class.new(Error)

    # Raised when conversion type isn't registered
    UnsupportedConversion = Class.new(Error)

    # Raised when argument value isn't permitted
    UnpermittedArgument = Class.new(Error)
  end # Option
end # TTY
