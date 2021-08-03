# frozen_string_literal: true

RSpec.describe TTY::Option do
  it "inherits parameters from parent class" do
    parent_class = command("ParentCmd") do
      option :foo do
        long "--foo string"
      end
    end

    child_class = command("ChildCmd", parent_class)

    expect(parent_class.parameters.map(&:key))
      .to eq(child_class.parameters.map(&:key))

    parent_cmd = parent_class.new
    child_cmd = child_class.new

    child_cmd.parse(%w[--foo b])
    parent_cmd.parse(%w[--foo a])

    expect(parent_cmd.params[:foo]).to eq("a")
    expect(parent_cmd.params.remaining).to eq([])
    expect(child_cmd.params[:foo]).to eq("b")
    expect(child_cmd.params.remaining).to eq([])
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

    child_cmd.parse(%w[--foo aa --bar bb])
    parent_cmd.parse(%w[--foo a --bar b], check_invalid_params: false)

    expect(parent_class.parameters.map(&:key)).to eq([:foo])
    expect(parent_class.parameters.options.map(&:key)).to eq([:foo])
    expect(parent_cmd.params[:foo]).to eq("a")
    expect(parent_cmd.params[:bar]).to eq(nil)
    expect(parent_cmd.params.remaining).to eq(%w[--bar b])

    expect(child_class.parameters.map(&:key)).to eq(%i[foo bar])
    expect(child_class.parameters.options.map(&:key)).to eq(%i[foo bar])
    expect(child_cmd.params[:foo]).to eq("aa")
    expect(child_cmd.params[:bar]).to eq("bb")
    expect(child_cmd.params.remaining).to eq([])
  end

  it "redefines option in child class" do
    parent_class = command("ParentCmd") do
      option :foo do
        long "--foo string"
      end
    end

    child_class = command("ChildCmd", parent_class) do
      ignore :foo

      option :foo do
        short "-f string"
      end
    end

    parent_cmd = parent_class.new
    child_cmd = child_class.new

    child_cmd.parse(%w[--foo aa -f bb], check_invalid_params: false)
    parent_cmd.parse(%w[--foo a -f b], check_invalid_params: false)

    expect(parent_class.parameters.map(&:key)).to eq([:foo])
    expect(parent_cmd.params[:foo]).to eq("a")
    expect(parent_cmd.params.remaining).to eq(%w[-f b])

    expect(child_class.parameters.map(&:key)).to eq([:foo])
    expect(child_cmd.params[:foo]).to eq("bb")
    expect(child_cmd.params.remaining).to eq(%w[--foo aa])
  end

  it "removes option in child class and adds new one" do
    parent_class = command("ParentCmd") do
      option :foo do
        long "--foo string"
      end

      option :bar do
        long "--bar string"
      end
    end

    child_class = command("ChildCmd", parent_class) do
      ignore :bar

      option :baz do
        long "--baz string"
      end
    end

    parent_cmd = parent_class.new
    child_cmd = child_class.new

    child_cmd.parse(%w[--foo aa --bar bb --baz cc], check_invalid_params: false)
    parent_cmd.parse(%w[--foo a --bar b --baz c], check_invalid_params: false)

    expect(parent_class.parameters.map(&:key)).to eq(%i[foo bar])
    expect(parent_cmd.params[:foo]).to eq("a")
    expect(parent_cmd.params[:bar]).to eq("b")
    expect(parent_cmd.params[:baz]).to eq(nil)
    expect(parent_cmd.params.remaining).to eq(%w[--baz c])

    expect(child_class.parameters.map(&:key)).to eq(%i[foo baz])
    expect(child_cmd.params[:foo]).to eq("aa")
    expect(child_cmd.params[:bar]).to eq(nil)
    expect(child_cmd.params[:baz]).to eq("cc")
    expect(child_cmd.params.remaining).to eq(%w[--bar bb])
  end
end
