# frozen_string_literal: true

RSpec.describe TTY::Option::Parser::ParamTypes do
  def type
    stub_const("Types", Class.new do
      extend TTY::Option::Parser::ParamTypes
    end)
  end

  context "argument?" do
    {
      "--foo"                   => false,
      "-f"                      => false,
      "foo=bar"                 => false,
      "foo"                     => true,
      "f"                       => true,
      "FOO=bar"                 => false,
      "something FOO=bar --foo" => true
    }.each do |input, result|
      it "returns #{result} for #{input.inspect}" do
        expect(type.argument?(input)).to eq(result)
      end
    end
  end

  context "env_var?" do
    {
      "--foo"                   => false,
      "-f"                      => false,
      "foo=bar"                 => false,
      "a=b"                     => false,
      "foo"                     => false,
      "FOO=bar"                 => true,
      "A=b"                     => true,
      "something FOO=bar --foo" => false
    }.each do |input, result|
      it "returns #{result} for #{input.inspect}" do
        expect(type.env_var?(input)).to eq(result)
      end
    end
  end

  context "keyword?" do
    {
      "--foo"                   => false,
      "-f"                      => false,
      "-fa=b"                   => false,
      "foo=bar"                 => true,
      "a=b"                     => true,
      "foo"                     => false,
      "FOO=bar"                 => false,
      "something FOO=bar --foo" => false
    }.each do |input, result|
      it "returns #{result} for #{input.inspect}" do
        expect(type.keyword?(input)).to eq(result)
      end
    end
  end

  context "option?" do
    {
      "--foo"                   => true,
      "-f"                      => true,
      "foo=bar"                 => false,
      "foo"                     => false,
      "f"                       => false,
      "FOO=bar"                 => false,
      "something FOO=bar --foo" => false
    }.each do |input, result|
      it "returns #{result} for #{input.inspect}" do
        expect(type.option?(input)).to eq(result)
      end
    end
  end
end
