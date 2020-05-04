# frozen_string_literal: true

RSpec.describe TTY::Option do
  it "inherits parameters from parent class" do
    parent_class = command("ParentCmd") do
      option :foo do
        long "--foo string"
      end
    end

    child_class = command("ChildCmd", parent_class)

    expect(parent_class.parameters.map(&:name))
      .to eq(child_class.parameters.map(&:name))

    parent_cmd = parent_class.new
    child_cmd = child_class.new

    child_cmd.parse(%w[--foo b])
    parent_cmd.parse(%w[--foo a])

    expect(parent_cmd.params[:foo]).to eq("a")
    expect(parent_cmd.remaining).to eq([])
    expect(child_cmd.params[:foo]).to eq("b")
    expect(child_cmd.remaining).to eq([])
  end

  it "adds new parameters in child class" do
    parent_class = command("ParentCmd") do
      option :foo do
        long "--foo string"
      end
    end

    child_class = command("ChildCmd", parent_class) do
      option :bar do
        long "--bar string"
      end
    end

    parent_cmd = parent_class.new
    child_cmd = child_class.new

    child_cmd.parse(%w[--foo a --bar b])
    parent_cmd.parse(%w[--foo a --bar b], check_invalid_params: false)

    expect(parent_class.parameters.map(&:name)).to eq([:foo])
    expect(parent_cmd.params[:foo]).to eq("a")
    expect(parent_cmd.params[:bar]).to eq(nil)
    expect(parent_cmd.remaining).to eq(%w[--bar b])

    expect(child_class.parameters.map(&:name)).to eq([:foo, :bar])
    expect(child_cmd.params[:foo]).to eq("a")
    expect(child_cmd.params[:bar]).to eq("b")
    expect(child_cmd.remaining).to eq([])
  end
end
