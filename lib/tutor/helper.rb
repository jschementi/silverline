module Tutor::Helper

  def render_tutor(options = {}, &block)
    options[:partial] = "#{Tutor::Render::TEMPLATE_PATH}" + options[:partial].to_s unless options[:partial].blank?
    render options, block
  end
  
  def tutor_javascript_includes
    output = <<-EOS
    <script type="text/javascript">
    var roundTutor = function() {
      var els = document.getElementsByTagName('div'); 
      for(var i=0; el=els[i]; i++) 
        if(el.className.indexOf('round')>-1 && el.firstChild && el.firstChild.className!='t') 
          el.innerHTML = '<b class="t"><b class="r"></b></b><div class="c"><b class="br"></b>'+el.innerHTML+'<b class="br"></b></div><b class="b"><b class="r"><!----></b></b>';
    }
    window.onload = function() {
      roundEverything()
      roundTutor()
    }
    </script>
    EOS
  end
  
end