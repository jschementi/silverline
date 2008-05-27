module AssistmentHelpers::Widgets

  # For documenation of the options, see: http://boxover.swazz.org/
  def boxover_tooltip(options = {})
     options.map { |key, value| "#{key}=[#{value}]" }.join(" ")
  end

  def render_indicator(options)
    defaults = {:pre => "", :style => ""}
    options = defaults.merge(options)
    pre = options[:pre] + "_" unless options[:pre].blank?
    output = "<span id='#{pre}indicator' style='display: none; #{options[:style]}'>"
    output << image_tag("indicator.gif")
    output << "</span>"
  end

  # Creates a select menu that starts with the default item given as the selected item
  def select_from_collection_with_default(object, attr, collection, default_text, default_value = 0, html_options = {})
    <<-FINISH
    <select id="#{object}_#{attr}" name="#{object}[#{attr}]" #{html_options.keys.collect { |key| "#{key}=#{html_options[key]}" }.join(" ")}>
      <option value="#{default_value}" selected="true">#{default_text}</option>
      #{options_for_select(collection)}
    </select>
    FINISH
  end

  # Creates a select menu that starts with the default item given as the selected item
  def select_from_collection_with_options(collection, options = {})
    html_options = { :id => "selector", :name => "selector" }.merge(options[:html] || {})
    select_id = html_options.delete(:id)
    default_option_id = select_id + '_default_option'

    default_option = %Q(<option id="#{default_option_id}" value="#{options[:default_value]}" selected="true">#{options[:default_text]}</option>) if options[:default_value] or options[:default_text]
    default_option ||= ""

    widget = <<-FINISH
    <select id="#{select_id}" name="#{html_options.delete(:name)}" #{html_options.keys.collect { |key| "#{key}=#{html_options[key]}" }.join(" ")}>
      #{default_option}
      #{options_for_select(collection)}
    </select>
    FINISH

    widget += observe_field(select_id, :function => %Q(if (value == 0 || $('#{default_option_id}') == null) { return; } Element.remove('#{default_option_id}');), :on => "select") if options[:default_value] or options[:default_text]

    widget
  end

  # Generate lines of JS that will generate YUI tree widget nodes using the given list
  #  List is expected to be such that all non-children nodes are either hashes or arrays, 
  #   where the children of an array node are strings, e.g. 
  #   { :hash1 => { :hash2 => ["string1", "string2"]}, :hash3 => ["string3", "string4"]}  
  def make_yui_node_lines(list, parent = 'root', level = 1)
    return [] unless (list.class <= Hash) or (list.class <= Array)
    lines = []
    name = "new_node"
    if list.class <= Array
      list.each_with_index do |item, index|
        name = "node_#{level}_#{index}" # Ensures parent is recognized correctly
        lines << make_yui_node_line(parent, item, name)
      end
    else
      list.keys.sort.each_with_index do |key, index|
        name = "node_#{level}_#{index}" # Ensures parent is recognized correctly
        lines << make_yui_node_line(parent, key, name)
        lines.push(*make_yui_node_lines(list[key], name, level + 1))
      end
    end
    lines
  end

  def make_yui_node_line(parent_name, label, var_name)
    %Q(var #{var_name} = new YAHOO.widget.TextNode({ label: '#{label}' }, #{parent_name}, false); #{var_name}.data['id'] = #{var_name}.labelElId;)
  end

  def hide_elements(element_ids)
    element_ids.collect { |id| "Element.hide('#{id}');" }.join(" ")
  end

  # Creates a select menu that starts with the specified item selected
  # 
  # - object: the name of the object whose attribute this menu affects
  # - attr: the name of the attribute this menu affects
  # - collection: the collection to be used (ala options_for_select)
  # - selected_value: the value of the option that will be selected
  def select_from_collection_with_selected(object, attr, collection, selected_value)
    <<-FINISH
    <select id="#{object}_#{attr}" name="#{object}[#{attr}]">
      #{options_for_select(collection, selected_value)}
    </select>
    FINISH
  end

  # Inserts an in-place collection select editing widget  
  #  Note: script_option values are put in as they are, so strings need to be quoted (e.g. "'my string'")
  #  (From http://pastie.caboo.se/46627, which was based on: http://fora.pragprog.com/rails-recipes/write-your-own/post/223)
  def in_place_collection_editor_field(object, method, container, tag_options = {}, script_options = {})
      tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
      tag_options = { :tag => "span",
        :id => "#{object}_#{method}_#{tag.object.id}_in_place_editor",
        :class => "in_place_editor_field" }.merge!(tag_options)
      url = url_for( :action => "set_#{object}_#{method}", :id => tag.object.id )
      collection = container.inject([]) do |options, element|
        options << "[ '#{escape_javascript(element.last.to_s)}', '#{escape_javascript(element.first.to_s)}']" 
      end
      function =  "new Ajax.InPlaceCollectionEditor("
      function << "'#{object}_#{method}_#{tag.object.id}_in_place_editor',"
      function << "'#{url}',"
      function << "{"
      function << "collection: [#{collection.join(',')}]"
      function << ", id: '#{object}_#{method}'" #, okText: 'blah'
      script_options.each_key do | option_key |
        function << ", #{option_key}: #{script_options[option_key]}"
      end
      function << "});"
      tag.to_content_tag(tag_options.delete(:tag), tag_options) + javascript_tag(function)
  end

  # http://blog.codahale.com/2006/01/14/a-rails-howto-simplify-in-place-editing-with-scriptaculous/
  # :content has three elements:
  #
  #    * :element This is the element type the content will be embedded in. It defaults to span, 
  #               but could just as easily be a div or any other (X)HTML element which has a CDATA section.
  #    * :text This is the text which is displayed at first. Usually the actual value of the attribute being 
  #            edited, unless it’s a markup rendering situation (e.g., textilizing). More on that later.
  #    * :options These are the attributes of the element, in the :attribute => 'value' you should already be used to.
  #          o :id This is the id of the element and is required for this method to work. Can’t find an element without 
  #                an id, dontchaknow.
  #
  # :url This contains the options for the update URL, and the format is the same as the parameters for url_for, 
  #      link_to or any other URL-based helper in Rails. You need to specify the controller, otherwise this function 
  #      won’t work (unless the controller is the default path).
  # :ajax Now this is the bit you don’t know about. The Script.aculo.us In Place Editor can take a list of options, 
  #       and this encapsulates that. If the value of one of these options is a string constant, you must add the 
  #       single-quotes around it yourself (e.g., :cancelText => "'Nevermind'"). You can read all about the various 
  #       parameters in the Script.aculo.us documentation.
  def editable_content(options)

     # Set in default values for options as needed and merge then with the specified options
     options[:content] = { :element => 'span' }.merge(options[:content])
     options[:update_url] = {}.merge(options[:update_url])
     options[:editor_options] = { :okText => "'Save'", :cancelText => "'Cancel'"}.merge(options[:ajax] || {})

     script = Array.new
     script << "new Ajax.InPlaceEditor("
     script << "  '#{options[:content][:options][:id]}',"
     script << "  '#{url_for(options[:update_url]).gsub('&amp;','&')}',"
     script << "  {"
     script << options[:editor_options].map{ |key, value| "#{key}: #{value}" }.join(", ")
     script << "  }"
     script << ")"

     content_tag(
       options[:content][:element],
       options[:content][:text],
       options[:content][:options]
     ) + javascript_tag( script.join("\n") )
  end

  def render_preview_link(type, item, contents = "Preview", title = contents)
    popup = {:popup => ["preview_#{type.to_s}", 'height=600,width=800,resize=1,scrollbars=1']}
    defaults = {:id => item.id }
    links = {
      :assistment =>  {:controller => "preview",    :action => "assistment" },
      :sequence   =>  {:controller => "preview",    :action => "sequence"   },
      :assignment =>  {:controller => "preview",    :action => "preview"    }
    }
    options = defaults.merge(links[type])
    link_to contents, options, popup.merge(:title => title)
  end

  # Creates a javascript script tag that will populate a JS array from the array given
  #  array: the array of objects to be put into a JS array
  #  array_name: the name of the JS array that will be created
  def define_javascript_array_tag(array, array_name)
    settings = ""
    array.each_with_index do | el, index |
      settings << "#{array_name}[#{index}] = #{array_or_string_for_javascript(el)};\n  "
    end
    <<-END
      <script type="text/javascript">
        var #{array_name} = new Array(#{array.size});
        #{settings}
      </script>
    END
  end

  def in_place_editor_field_on_complete(object, method, on_complete, tag_options = {}, in_place_editor_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = {:tag => "span", :id => "#{object}_#{method}_#{tag.object.id}_in_place_editor", :class => "in_place_editor_field"}.merge!(tag_options)
    in_place_editor_options[:url] = in_place_editor_options[:url] || url_for({ :action => "set_#{object}_#{method}", :id => tag.object.id })

    extra = <<-OVER
<script type="text/javascript">
//<![CDATA[
  new Ajax.InPlaceEditor('#{object}_#{method}_#{tag.object.id}_in_place_editor', '/build/#{object}/set_#{object}_#{method}/#{tag.object.id}', { onComplete: function(form, value) { #{on_complete} }})
//]]>
</script>
    OVER

    tag.to_content_tag(tag_options.delete(:tag), tag_options) + extra
    #in_place_editor(tag_options[:id], in_place_editor_options)
  end

end