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

class NestedFunctions
  def initialize
    @simple = Simple.new
  end

  def call
    shallow_call
    @simple.simple_call
  end

  def shallow_call
    normal_call
  end

  def normal_call
    deep_call
  end

  def deep_call; end
end
