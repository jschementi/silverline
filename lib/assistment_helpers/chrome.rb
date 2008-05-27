module AssistmentHelpers::Chrome
  
  def render_head_for(name)
    send "render_head_for_#{name}"
  end

  def render_subtitle_for(name)
    send "render_subtitle_for_#{name}"
  end

  def render_head_for_tutor
    %Q(
      #{ stylesheet_link_tag "tutor" }
      #{ render_default_head } 
      #{ tutor_javascript_includes }
      #{ render_title(:subject => "Tutor") }
    )
  end

  def render_head_for_build
    %Q(
      #{ stylesheet_link_tag "build"}
      #{ render_default_head }
      #{ javascript_include_tag "boxover" }
      #{ render_title(:subject => "Build") }
    )
  end

  def render_default_head
    %Q(
    <!--[if lte IE 6]>
      #{stylesheet_link_tag "ie"}
    <![endif]-->

    <!-- compliance patch for pre IE7 microsoft browsers -->
    <!--[if lt IE 7]>#{ javascript_include_tag "ie7/ie7-standard-p" }<![endif]-->

    #{ javascript_include_tag :defaults }
    #{ rounding_javascript_includes }
    )
  end

  def render_subtitle_for_tutor
    %Q(
    <span class="subtitle" id="assistment_id">
      #{ "Assistment ##{@assistment.id}" unless @assistment.nil? }
    </span>
    )
  end

  def render_subtitle_for_build
    render_subtitle_for_page
  end
  
  def render_subtitle_for_page
    %Q(
    <span class="breadcrumbs">
      #{render :partial => "layouts/breadcrumbs"}
    </span>
    )
  end
  
end