# frozen_string_literal: true

RSpec.describe TTY::Option::Result do
  it "wraps a value in success" do
    result = described_class.success("11")

    expect(result.success?).to eq(true)
    expect(result.value).to eq("11")
    expect(result.error).to eq(nil)
  end

  it "wraps an error in failure" do
    error = ArgumentError.new("boom")
    result = described_class.failure(error)

    expect(result.failure?).to eq(true)
    expect(result.value).to eq(nil)
    expect(result.error).to eq(error)
  end
end
