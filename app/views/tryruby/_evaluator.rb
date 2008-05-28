def compute
  @code = document.code.value.to_s
  @result = eval(@code) unless @code == ""
rescue => e
  @result = e.class
ensure
  document.result.innerHTML = 
    "#{document.result.innerHTML}#{"<br />" unless document.result.innerHTML.to_s == ""}<span id=\"prompt\">&raquo;&nbsp;</span>"
  unless @code == ""
    document.result.innerHTML = "#{document.result.innerHTML}#{@code}<br />#{@result}"
  end
  document.code.value = ""
end

def move_on
  @instructions ||= nil
  @instructions.nil? ? get_instructions : next_instruction
end

def get_instructions(&block)
  download "/tryruby/instructions.json" do |s, a|
    @instructions = JSON.parse a.result
    move_on
  end
end

def next_instruction
  @current ||= 0
  document.instructions.innerHTML = @instructions[@current].to_s
  @current += 1 if @current < @instructions.size - 1
end

def hook_run
  document.run.onclick do |s, a|
    document.loading.innerHTML = "<img src='/images/loading.gif' alt='evaluating ...' />"
    compute
    move_on
    document.loading.innerHTML = ''
    HtmlPage.window.eval "moveTo('console', 'code')"
  end
end

document.code.value = ""
document.code.focus
hook_run
get_instructions
