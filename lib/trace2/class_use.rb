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

  def matches_method?(methods_names)
    methods_names.any? { |method_name| method.match(method_name) }
  end

  def matches_name?(classes_names)
    classes_names.any? { |class_name| name.match(class_name) }
  end

  def matches_path?(paths_patterns)
    paths_patterns.any? { |path_pattern| path.match(path_pattern) }
  end

  def matches_top_of_stack?(is_top)
    top_of_stack == is_top
  end

  def matches_caller_class?(caller_attributes)
    callers_stack.any? do |current_caller|
      valid_caller?(current_caller, caller_attributes)
    end
  end

  private

  def valid_caller?(current_caller, caller_attributes)
    caller_attributes.all? do |attribute, values|
      validation = "matches_#{attribute}?"
      current_caller.send(validation, values)
    end
  end

  def respond_to_missing?(method, _)
    method.match?(/^matches_\S+?\?$/)
  end

  def method_missing(method, *args, &block)
    return true if respond_to_missing?(method, args)

    super
  end
end
