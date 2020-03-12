# frozen_string_literal: true

# Registers how a class was used during run time
class ClassUse
  attr_reader :name, :method, :stack_level, :path, :line, :callees, :event
  attr_accessor :caller_class, :top_of_stack

  def initialize(params)
    @name = params[:name]
    @method = params[:method]
    @caller_class = params[:caller_class]
    @stack_level = params[:stack_level]
    @path = params[:path]
    @line = params[:line]
    @top_of_stack = params[:top_of_stack]
    @callees = params[:callees] || []
    @event = params[:event]
  end

  def callers_stack(options = {})
    curr_class = caller_class
    callers_stack = []
    until curr_class.nil?
      curr_caller = run_options(curr_class, options)
      callers_stack.push(curr_caller) unless curr_caller.nil?
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

  def add_callee(callee)
    callees << callee
  end

  private

  def run_options(class_use, options)
    options.reduce(class_use) do |acc_use, option|
      option_method = "run_#{option.first}"
      send(option_method, acc_use, option.last) unless acc_use.nil?
    end
  end

  def run_selector(class_use, selector)
    return class_use if selector.nil?

    selector.filter(class_use)
  end

  def run_compact(class_use, compact)
    compact ? compact_callers(class_use) : class_use
  end

  def compact_callers(class_use)
    class_use.dup.tap do |compacted_use|
      compacted_use.caller_class = nil
    end
  end

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
