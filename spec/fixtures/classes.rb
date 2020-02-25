# frozen_string_literal: true

class Simple
  def simple_call; end
end

class Nested
  def initialize
    @simple = Simple.new
  end

  def nested_call
    @simple.simple_call
  end

  def nested_simple_call; end
end

class ComplexNesting
  def initialize
    @simple = Simple.new
    @nested = Nested.new
  end

  def complex_call
    @simple.simple_call
    @nested.nested_call
    complex_simple_call
    @nested.nested_simple_call
  end

  private

  def complex_simple_call; end
end

class BlockUse
  def simple_block(&block)
    block.call
  end
end
