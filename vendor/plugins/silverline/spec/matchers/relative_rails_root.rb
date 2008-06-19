RAILS_ROOT = "config/.."

module CustomPathMatchers
  class BeRelativeTo
    def initialize(expected)
      @expected = expected
    end
    
    def matches?(target)
      @target = target
      @target == "#{RAILS_ROOT}#{@expected}"
    end

    def failure_message
      "expected #{@target.inspect} to be '#{RAILS_ROOT}#{@expected}'"
    end

    def negative_failure_message
      "expected #{@target.inspect} not to be '#{RAILS_ROOT}#{@expected}'"
    end
  end

  def be_relative_to(expected)
    BeRelativeTo.new(expected)
  end
end

#Spec::Runner.configure do |config|
#  config.include(CustomGameMatchers)
#end

