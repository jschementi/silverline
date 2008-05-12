require '../lib/rails/erb'

@x = "ERB works!"
$template = <<-EOS
  The value of x is "<%= @x %>"
EOS

$erb = ERB.new $template
puts $erb.result(binding)