# frozen_string_literal: true

RSpec.describe TTY::Option::Inflection do
  context "demodulize" do
    {
      "A::B::C::Name" => "Name",
      "::Name" => "Name",
      "Name" => "Name"
    }.each do |with_modules, bare_class|
      it "removes all preceding modules from #{with_modules.inspect}" do
        expect(described_class.demodulize(with_modules)).to eq(bare_class)
      end
    end
  end

  context "underscore" do
    {
      "SomeClassName" => "some_class_name",
      "MacOS" => "mac_os",
      "HTMLClass" => "html_class",
      "SomeHTMLClass" => "some_html_class",
      "IPV6Class" => "ipv6_class"
    }.each do |class_name, underscored|
      it "converts #{class_name.inspect} to #{underscored.inspect}" do
        expect(described_class.underscore(class_name)).to eq(underscored)
      end
    end
  end

  context "dasherize" do
    it "removes all preceding modules" do
      expect(described_class.dasherize("SomeClassName")).to eq("some-class-name")
    end
  end
end
