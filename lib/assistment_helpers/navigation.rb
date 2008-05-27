# Holds classes for site navigation
module AssistmentHelpers::Navigation

  # renders the main navigation of the site
  def render_navigation
    Menu.new(controller, self).render
  end
  
  # renders the submenu of the site
  def render_submenu(controller, view, &proc)
    SubMenu.new(controller, self).render(&proc)
  end

  # sets up and renders the menu 
  class Menu
    
    # sets up a Menu
    def initialize(controller, view)
      @controller = controller
      @view = view
    end
    
    # Set any menu links here (except Account, that is built-in)
    # TODO: don't store the role name here ... use the Rails Routing API
    # to convert a URL to a "link_to options" hash and check if the user
    # has the appropriate rights
    MENU = [
      {:title => "Build", :controller => "build", :role => "ContentCreator"},
      {:title => "Tutor", :controller => "tutor", :role => "Student"},
      {:title => "Assess", :controller => "teacher", :role => "Teacher"},
      {:title => "Admin", :controller => "admin", :role => "Administrator"},
      {:title => "Account", :controller => "account", :role => ""}
    ]
    
    # decides if this link should be shown or not
    def show_link?(controller_path, role)
      controller_path.include?("tutor") || controller_path.include?("build")
    end
    
    # render the menu
    def render
      navigation = ""
      navigation << %Q(<div class="menu">)
      @count = -1
      MENU[0..-2].each do |link|
        @count += 1
        next unless show_link?(link[:controller], link[:role])
        navigation << Link.new(self, @view, link[:title], link[:controller]).render
      end
      @count += 1
      link = MENU[@count]
      navigation << "</div>"
    end
    
    # is this link the active page?
    def active?
      _active?(@count)
    end
    
    # tells whether the link is active, where the link is represented 
    # by the count in MENU. The account link is a special case where it is
    # only active if we've checked all other links and the module names match
    def _active?(count)
      ret =  (MENU[count][:controller] == @view.module_name)
      unless ret
        return (count + 1 == MENU.size && "account" == @view.module_name)
      end
      return ret
    end

  end
  
  # sets up and renders a menu link
  class Link
  
    # constructs a link
    def initialize(menu, view, title, controller_path)
      @menu = menu
      @title = title
      @controller_path = controller_path
      @view = view
    end
    
    # renders a link
    def render
      nav_link = ""
      nav_link << "<div class='tab'>"
      nav_link <<   "<div class='"
      nav_link <<   " menu_active" if @menu.active?
      #nav_link <<   " account" if @controller_path == "account"
      nav_link <<   "'"
      nav_link <<   " id='#{@controller_path}_link'"
      nav_link <<   ">\n"
      nav_link <<     "<div class='autoPadDiv'>"
      nav_link <<       @view.link_to(@title.capitalize, {:controller => "/#{@controller_path}"})
      nav_link <<     "</div>"
      nav_link <<   "</div>"
      nav_link << "</div>"
      nav_link
    end
    
  end
  
  # setup and renders a submenu
  class SubMenu
  
    attr_reader :controller
    
    def initialize(controller, view)
      @controller = controller; @view = view
    end
    
    # accepts a block to render the actual links
    def render(&proc)
      #concat("<ul>", proc.binding)
      yield(self)
      #concat("</ul>", proc.binding)
    end
    
    # should be called from the block passed to render
    # delegates rendering the link to the SubMenuLink class
    def render_link(path, name)
      SubMenuLink.new(self, @controller, @view, path, name).render
    end
    
  end
  
  # setup and renderes a submenu link
  class SubMenuLink
  
    def initialize(menu, controller, view, path, name)
      @menu, @controller, @view, @path, @name = menu, controller, view, path, name
    end
    
    # simply renders the link
    def render
      output = "<span "
      output << "#{render_active}>"
      link = "#{@name}"
      output << @view.link_to(link, :controller => @path)
      output << "</span>"
      output
    end
    
    # if the link is active (we are viewing the page the link links to)
    # return the proper html to make it active
    def render_active
       (@controller.controller_name == @path) ? "class='active'" : ""
    end    

  end
  
end