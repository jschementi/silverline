def compute
  @code = $d.code.value.to_s
  @result = eval(@code, console_binding) unless @code.empty?
rescue => e
  @result = e.class
ensure
  show_result
  @code = @result = nil
end

def show_result
  $d.result.append(tag("span", :id => 'prompt') { "&raquo;&nbsp;" })
  $d.result.append(@code.empty? ? tag("br") : "#{tag("span"){ @code }}#{tag("div"){ @result.inspect }}")
  $d.code.value = ""
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
  $d.instructions.html = @instructions[@current].to_s
  @current += 1 if @current < @instructions.size - 1
end

def hook_run
  $d.run.onclick do |s, a|
    document.loading.html = tag('img', :src => '/images/loadinfo.net.gif', :alt => 'evaluating ...')
    compute
    move_on
    document.loading.html = ''
    HtmlPage.window.eval "moveTo('console', 'code')"
  end
end

def console_binding
  binding
end

$d.code.value = ''
$d.code.focus
hook_run
get_instructions
