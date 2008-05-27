module AssistmentHelpers::Render
  
  def render_title(options = {})
    title = "<title>Assistment "
    title << "&raquo; #{module_name.capitalize} "
    title << "&raquo; #{controller.controller_name.split("_").collect{|n| n.capitalize}.join(" ").pluralize}" unless controller.controller_name == "home"
    title << "</title>"
  end

  # checks to see if msg actually contains content
  def msg_exists(msg) 
    not msg.nil? and not msg.empty?
  end
  
  def render_container(title, new_rendering = nil, options = {}, &proc)
    if options[:id]
      title = link_to_function title, nil do |page|
        page["#{options[:id]}_container_body"].toggle
        page["#{options[:id]}_hidden_message"].toggle if options[:hidden_message]
      end
    end
    concat( 
      %Q(<div style="#{options[:style] if options[:style]}" id="#{options[:id] if options[:id]}" class="#{ "spaced " if options[:spaced] }container#{ " " + options[:class] if options[:class] }">
          <div class="container_left">&nbsp;</div>
          <div class="container_round_left">&nbsp;</div>
          <div class="container_repeat">&nbsp;</div>
          <div class="container_round_right">&nbsp;</div>
          <div class="container_right">&nbsp;</div>
          <div class="container_header">
            <h4>#{title}</h4>
          </div>
          <div class="container_body" style="#{"display: none" if options[:hidden]}" id="#{(options[:id]+"_container_body") if options[:id]}">
      ), proc.binding)
    yield
    concat(new_rendering, proc.binding) unless new_rendering.nil?
    concat(
      %Q(
        </div>
        #{
          if options[:hidden_message]
          %(<div id="#{(options[:id]+"_hidden_message") if options[:id]}" style="#{"display: none" unless options[:hidden]}">
            #{render_message(:help => options[:hidden_message])}
          </div>)
          end
        }
      </div>
      ), proc.binding)
  end

  def render_message(message)
    %(<div class="#{message.keys.first.to_s}_message">
        #{message[message.keys.first]}
      </div>)
  end

  # renders a flash message of a specific type if it is set 
  def render_flash(type, options = {})
    defaults = { :id => "", :class => "", :style => "" }
    options = defaults.merge(options)
    unless flash[type].nil?
      %Q(<h3 id="flash_#{type}#{"_#{options[:id]}" unless options[:id].empty?}" 
             class="flash_#{type}#{" #{options[:class]}" unless options[:class].empty?}" 
             style="#{options[:style]}">#{flash[type]}</h3>)
    else
      ""
    end
  end

  # Insert a temporary "flash" message
  #  The message disappears after 'delay' seconds
  #
  #  position: the position (relative to the 'element') in which the flash will be inserted
  #  element: the id of the element relative to which the flash will be inserted
  #  type: the type of flash that will be rendered [:notice, :warning, etc.]
  #  delay: the number of seconds that the flash message will remain before going away
  def insert_flash(page, position, element, type, options = {}, delay = "5")
    page.insert_html(position, element, render_flash(type, options))
    page.delay(delay) do
      page.remove("flash_#{type.to_s}#{"_#{options[:id]}" unless options[:id].blank?}")
    end
  end

  # replaces a flash of a certain type
  def replace_flash(page, flash_type, options = {})
    flash_id = "flash_#{flash_type}"
    if page.select("#"+flash_id).count > 0
      page.replace id, :partial => "layouts/flash"
    end
  end

  # Creates a standard image_tag for an indicator icon 
  #  (for indicating when new data is loading into the view)
  def indicator_tag(id = 'indicator', alt = 'Loading...')
    image_tag 'indicator.gif', :style => 'display: none;', :id => id, :alt => alt
  end

  def indicator_span(image_content = image_tag("indicator.gif", :id => "indicator"))
    %Q(
      <div id="loading_indicator" class="container_indicator" style="padding-top: 4px; display: none;">
        #{image_content}
        <span>Loading...</span>
      </div>
    )
  end

  def rounding_javascript_includes
    %Q(
      #{javascript_include_tag "rounded_corners.inc.js"}
      <script type="text/javascript">
        roundEverything = function()
        {
          settings = {
              tl: { radius: 10 },
              tr: false,
              bl: false,
              br: { radius: 10 },
              antiAlias: true,
              autoPad: true
          }
          portal_settings = {
            tl: { radius: 10 },
            tr: { radius: 10 },
            bl: { radius: 10 },
            br: { radius: 10 },
            antiAlias: true,
            autoPad: true
          }

          if(document.getElementsByClassName("help_message").size() != 0) {
            var helpMessage = new curvyCorners(settings, "help_message");
            helpMessage.applyCornersToAll();
          }
          if(document.getElementsByClassName("warning_message").size() != 0) {
            var warningMessage = new curvyCorners(settings, "warning_message");
            warningMessage.applyCornersToAll();
          }
          if(document.getElementsByClassName("content help_message").size() != 0) {
            var portalMessages = new curvyCorners(portal_settings, "content help_message");
            portalMessages.applyCornersToAll();
          }
          if(document.getElementsByClassName("login_window").size() != 0) {
            var loginWindow = new curvyCorners(portal_settings, "login_window");
            loginWindow.applyCornersToAll();
          }
          var menuId = document.getElementById("submenu_content")
          if(menuId != null) {
            var menu = new curvyCorners({
              tl: false,
              tr: false,
              bl: { radius: 5 },
              br: { radius: 5 },
              antiAlias: true,
              autoPad: true
            }, menuId);
            menu.applyCornersToAll();
          }
          if(document.getElementsByClassName("menu_active").size() != 0) {
            var active = new curvyCorners({
              tl: { radius: 5 },
              tr: { radius: 5 },
              bl: false,
              br: false,
              antiAlias: true,
              autoPad: false
            }, "menu_active");
            active.applyCornersToAll();
          }
          tag_settings = {
        	    tl: { radius: 1 },
        	    tr: { radius: 1 },
        	    bl: { radius: 1 },
        	    br: { radius: 1 },
        	    antiAlias: true,
        	    autoPad: true
        	}
          if(document.getElementsByClassName("assistment_id_tag tag").size() != 0) {
          	var ids = new curvyCorners(tag_settings, "assistment_id_tag tag");
          	ids.applyCornersToAll();
          }
        }
        window.onload = function() {
          roundEverything()
        }
      </script>
    )
  end
end