# frozen_string_literal: true

# Registers how a class was used during run time
class ClassUse
  attr_reader :name, :method, :stack_level, :caller_class, :path, :line
  attr_accessor :top_of_stack

  def initialize(params)
    @name = params[:name]
    @method = params[:method]
    @caller_class = params[:caller_class]
    @stack_level = params[:stack_level]
    @path = params[:path]
    @line = params[:line]
    @top_of_stack = params[:top_of_stack]
  end

  def callers_stack
    curr_class = caller_class
    callers_stack = []
    until curr_class.nil?
      callers_stack.push(curr_class)
      curr_class = curr_class.caller_class
    end
    callers_stack
  end
end
