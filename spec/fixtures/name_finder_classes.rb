# frozen_string_literal: true

module NormalModule; end
class NormalClass; end
module NormalModule
  class ClassInside
  end
end

class ToSRaisesError
  def self.to_s
    raise 'Name will be parsed anyway'
  end
end

class ToSNil
  def self.to_s
    nil
  end
end
