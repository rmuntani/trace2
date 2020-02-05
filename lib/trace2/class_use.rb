class ClassUse
  FIRST_CAPTURE_GROUP = 1

  attr_reader :caller_name, :call_stack, :name, :method

  def initialize(name: nil, method: nil, caller_name: nil, call_stack: nil)
      @name = name
      @method = method
      @caller_name = caller_name
      @call_stack = call_stack
  end

  def self.build(trace_point, call_stack, possible_callers)
    class_use = ClassUse.new(
      call_stack: call_stack, 
      name: trace_point.defined_class.to_s,
      method: trace_point.callee_id
    )
    class_use.set_caller(possible_callers)
    class_use
  end

  def set_caller(possible_callers)
    @caller_name = find_caller_name(possible_callers)
  end

  private 

  def find_caller_name(possible_callers)
    caller_method = parse_caller_method
    caller_class = possible_callers&.find do |caller_class| 
      caller_class.method == caller_method
    end
    return if caller_class.nil?

    caller_class.name
  end

  def parse_caller_method
    caller_line = @call_stack[1]
    caller_method = caller_line.match(/\`(\S+)'$/) if caller_line

    return nil if caller_method.nil?

    caller_method[FIRST_CAPTURE_GROUP]
  end
end
