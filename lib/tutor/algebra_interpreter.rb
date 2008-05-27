# Helper class to check if two algebraic expressions are equal. Does this by
# generating random values for the variables in each equation a number of times
# and making sure on each iteration that their evaluation is the same.
#
module Tutor::AlgebraInterpreter
  
  # Check if the math expression1 is algebraically equivalent to
  # expression2 within an epsilon (defaulted to 0.0001).
  #
  # Returns true if equal, false otherwise
  #
  # Examples:
  #          expressions_eq?("3x+4y", "4y+3x") -> true
  #          expressions_eq?("4yz + 5xy", "4yz + 5xz") -> false
  #          expressions_eq?("4*x*x*x", "4x^3") -> true
  #          expressions_eq?("1 1/3", "1.3333") --> true
  #          expressions_eq?("1 -2/-3", "1.66666") --> true
  #          expressions_eq?("(x-2)(x-5)", "(x-5)*(x-2)") --> true
  #          expressions_eq?("(l+h)w", "w( h + l )") --> true
  def expressions_eq?(expression1, expression2, epsilon = 0.0001)
    
    # Preprocess strings by adding appropriate operators to the strings
    expression1.downcase!
    expression2.downcase!
    parsed_exp1 = parse(expression1)
    parsed_exp2 = parse(expression2)
    
    # Walk both expressions and collect the unique letter variables (vars).
    vars = (expression1+expression2).delete('^a-z').split(//).uniq
    
    # Try assigning random values to the variables in the equations and
    # check if they yield equal evaluations. If they do for N iterations,
    # we declare them equal.
    10.times do
      
      # Assign the variables (local scope)
      # This is equivalent to typing "a=43";"b=12" in the interpreter.
      for var in vars
        eval("#{var} = 1+rand(20)")
      end
      
      # Check if the two equations are equal using the assigned
      # values from above. Since we could deal with floats, you need
      # to check that they're within an epsilon to account for rounding
      # errors.
      #
      # If the expression cannot be evaluated (parses incorrectly), trap
      # the error and return false.
      #
      # Note: divide by zero will be returned as Infinity since all evaluations
      #       are float computations.
      begin
        val1 = eval(parsed_exp1)
        val2 = eval(parsed_exp2)
        diff = ( val1 - val2 ).abs
        return false if (diff > epsilon)
      
      rescue SyntaxError
        logger.error "AlgebraInterpreter: Cannot parse/evaluate expressions"
        logger.error expression1 + "  ==>  " + parsed_exp1
        logger.error expression2 + "  ==>  " + parsed_exp2
        return false
      end
      
    end
    
    return true
  end
  
private
  
  # Inserts appropriate operators into algebraic string to make sure it
  # can be evaluated using "eval".
  #
  # Returns a new string with these operators based on the input string.
  #
  # Examples:
  #   "1 1/3" --> "1 + 1/3"
  #   "4xy" --> "4*x*y"
  #
  def parse(expression)
    
    return "0" if expression.blank?
    
    # Phase 0: Take out any HTML if present
    parsed = expression.gsub(/<(\/|\s)*[^>]*>/,'')
    
    # Phase 1: Replace certain operations, clean extraneous symbols
    parsed.gsub!("^", "**")
    parsed.gsub!("%", "/100")
    parsed.gsub!(/[$,]/, "")
    
    # Phase 2: Turn the input algebra string into something that can be
    #          evaluated using eval
    
    # Fix to handle ".33" and "33." as only character in list (the replacements below will
    # fail otherwise)
    parsed = ' ' + parsed + ' '
    
    # Replace .33 with 0.33 or 2 +.1 with 2 +0.1
    parsed.gsub!(/([^0-9])\.([0-9])/, '\10.\2')
    
    # Replace 24360. with 24360
    parsed.gsub!(/([0-9])\.\s+/, '\1')
    
    # Replace xy with x*y
    parsed.gsub!(/([a-z])\s*([a-z])/, '\1*\2')
    
    # Replace 34xyz with 34*x*y*z
    parsed.gsub!(/([0-9a-z])\s*([a-z])/, '\1*\2')
    parsed.gsub!(/([a-z])\s*([0-9])/, '\1*\2')
    
    # Replace "# #/#" with "(# + #/#)"
    parsed.gsub!(/([0-9]+)\s+([0-9]+\/[0-9]+)/, '(\1+\2)')
    
    # Replace something( with something*(
    parsed.gsub!(/([0-9a-z]\s*)\(/, '\1*(')
    
    # Replace )something with )*something
    parsed.gsub!(/\)\s*([0-9a-z])/, ')*\1')
    
    # Replace (something)(something) with (something)*(something)
    parsed.gsub!(/\)\s*\(/, ')*(')
    
    # Turn all numbers into floats
    # (prevents inequality of 1/3 and .3333)
    parsed.gsub!(/([0-9]+)(\.[0-9]+)*/, 'Float(\1\2)')
    
    return parsed
  end
  
end