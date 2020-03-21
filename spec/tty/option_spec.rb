# frozen_string_literal: true

RSpec.describe TTY::Option do
  it "has a version number" do
    expect(TTY::Option::VERSION).not_to be nil
  end
end
