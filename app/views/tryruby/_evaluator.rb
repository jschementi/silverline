class Tutorial
  attr_reader :current
  
  def get_instructions
    $app.download "/tryruby/instructions.json" do |s, a|
      @instructions = JSON.parse a.result
      move_on
    end
  end
  
  def next_instruction
    @current ||= 0
    $d.instructions.html = @instructions[@current].to_s
    @current += 1 if @current < @instructions.size - 1
  end
  
  def move_on
    @instructions ||= nil
    @instructions.nil? ? get_instructions : next_instruction
  end
end

def run_code
  @multiline = true
  @code = $d.code.value.to_s
  @result = eval @code unless @code.empty?
  @multiline = false
rescue => e
  @result = e.class
  @multiline = false
ensure
  unless @multiline
    show_prompt
    show_result(@code, @result)
    show_defaults
    scroll_to_code
    remember
    reset
  else
    $d.code.style[:height] = "#{$d.code.style[:height].to_s[0..-2].to_i + 20}px"
    show_prompt
    show_loaded
    $d.prompt.html = sub_prompt_html
  end
end

def remember
  @history ||= []
  @history << @code
end

def reset
  @code = @result = @multiline = @multiline_prompt = nil
end

def show_result(code, result)
  code = code.split("\n")
  @line_count = code.size
  code = code.collect do |line| 
    tag("div", :class => 'line') do
      line.gsub(" ", "&nbsp;")
    end
  end.join.strip
  $d.result.append(
    if code.empty?
      tag("br") 
    else 
      tag("div", :class => "expression"){ code } + tag("div"){ result.inspect }
    end
  )
end

def show_prompt
  $d.result.append(tag("div", :class => 'prompt') do 
    @multiline_prompt ? sub_prompt_html : prompt_html
  end)
  @multiline_prompt = true if @multiline
end

def prompt_html
  "&raquo;&nbsp;"
  #"ir&gt;&nbsp;"
end

def sub_prompt_html
  "|&nbsp;"
end

def show_defaults
  $d.code.value = ""
  $d.code.focus
  $d.prompt.html = prompt_html
  $d.code.style[:height] = "20px"
  $d.code.rows = "1"
end

def show_loading
  $d.loading.html = tag('img', 
    :src => '/images/loadinfo.net.gif', :alt => 'evaluating ...')
end

def show_loaded
  $d.loading.html = ''
end

def scroll_to_code
  scroll_to('code')
end

def scroll_to(element)
  HtmlPage.window.eval "moveTo('console', '#{element}')"
end

KEYS = {
  13 => 'run'
}

@tutorial = Tutorial.new
@tutorial.get_instructions
show_defaults

$d.code.onkeypress do |s, a|
  case a.character_code
  when 13 
    show_loading
    run_code
    @tutorial.move_on
    show_loaded
  when 38
  
  when 40
  end
  $d.code.value.strip!
end

# Demo script
$d.code.value = "'Welcome to IronRuby'"
run_code