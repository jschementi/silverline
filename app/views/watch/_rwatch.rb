render :partial => "watch", :properties => { :type => "Canvas" }

def content
  Application.current.host.content
end
#root.width = HtmlPage.window.eval("screen.width").to_i
#root.height = HtmlPage.window.eval("screen.height").to_i

# Toggle indiglow =) ##########################################
root.DayButton.mouse_left_button_down do |s, e|
  animation = @day ? root.Night : root.Day
  animation.begin
  @day = !@day
end

# Side watch buttons ########################################## 
root.BottomButton.mouse_left_button_down do |s, e|
  s.PressBottomButton.begin
  s.StartChronograph.stop
  @chronograph_state = 0
  @bottom_button_pressed = s.capture_mouse
end

root.BottomButton.mouse_left_button_up do |s, e|
  if @bottom_button_pressed
    s.ReleaseBottomButton.begin
    @bottom_button_pressed = false
  end
end

root.TopButton.mouse_left_button_down do |s, e|
  s.PressTopButton.begin
  @top_button_pressed = s.capture_mouse
  a = s.StartChronograph
  case @chronograph_state
  when 0
    s.PressTopButton.begin
    @chronograph_state = 1
  when 1
    s.PressTopButton.pause
    @chronograph_state = 2
  when 2
    s.PressTopButton.resume
    @chronograph_state = 1
  end
end

root.TopButton.mouse_left_button_up do |s, e|
  if @top_button_pressed
    s.ReleaseTopButton.begin
    @top_button_pressed = false
  end
end

=begin
# Informational buttons #######################################
def open_link(s, e)
  HtmlPage.window.navigate(s.tag, "_blank")
end
root.Info.mouse_left_button_down {|s,e| open_link(s,e)}
root.Logo.mouse_left_button_down {|s,e| open_link(s,e)}

def show_about
  animation = @about_show ? root.HideAbout : root.ShowAbout
  animation.begin
  @about_show = !@about_show
  root.About.Visibility = "Visible"
end
root.AboutButton.mouse_left_button_down {|s,e| show_about}
root.About.mouse_left_button_down {|s,e| show_about}
=end

# Fullscreen/Resizing #########################################
root.FullScreen.mouse_left_button_down do |s,e|
  content.IsFullScreen = !content.IsFullScreen
end

def on_resized
  resize(content.ActualWidth, content.ActualHeight)
end
content.resized {|s,e| on_resized}
content.full_screen_changed {|s,e| on_resized}

def resize(width, height)
  return if width == 0 || height == 0
  width = [width, HtmlPage.window.eval('screen.width').to_i].min
  height = [height, HtmlPage.window.eval('screen.height').to_i].min
  scalex = width / root.Watch.width
  scaley = height / root.Watch.height
  scale = [scalex, scaley].min
  root.PageScale.ScaleX = scale
  root.PageScale.ScaleY = scale
  root.PageTranslation.x = (width - root.Watch.width * scale) / 2.0
  root.PageTranslation.y = (height - root.Watch.height * scale) / 2.0
end

# Actual Clock logic; set up second animations ##########################
def update_second_animation(name)
  animation = root.send(name) 
  animation.key_frames.clear
  60.times do |i|
    animation.key_frames.add Markup::XamlReader.load(
      tag("DiscreteDoubleKeyFrame", {
        :xmlns => "http://schemas.microsoft.com/client/2007", 
        :KeyTime => "00:00:#{i < 10 ? "0#{i}" : i}", 
        :Value => "#{i * 6}"
      })
    )
  end
end

# Start the clock with "now" time #######################################
def run
  time = DateTime.Parse(Time.now.to_s);
  root.Run.begin
  root.Run.seek time.time_of_day
  root.DateNumber.Text = time.day.to_s
  root.Day.begin
end

@about_shown = false
@day = true
@top_button_pressed = false
@bottom_button_pressed = false
@chronograph_state = 0 # 0=stopped, 1=running, 2=paused

#root.width = HtmlPage.window.eval('screen.width').to_i
#root.height = HtmlPage.window.eval('screen.height').to_i
resize(content.actual_width, content.actual_height)

update_second_animation("SecondAnimation")
update_second_animation("ChronographSecondAnimation")
run
