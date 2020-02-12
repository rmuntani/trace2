# frozen_string_literal: true

# Filters class usage depending on the input
class FilterUsage
  def initialize(path: nil)
    @path = path
  end

  def run(class_use)
    return class_use unless @path

    filter_by_path(class_use)
  end

  private

  def filter_by_path(class_use)
    return nil if class_use.call_stack.first.match(@path)

    class_use
  end
end
