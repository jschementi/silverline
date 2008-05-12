# TODO: implement caching?
class Brushes
  def self.black
    SolidColorBrush.new(Color.from_argb(0xff, 0x00, 0x00, 0x00))
  end

  def self.white
    SolidColorBrush.new(Color.from_argb(0xff, 0xff, 0xff, 0xff))
  end

  def self.green
    SolidColorBrush.new(Color.from_argb(0xff, 0x00, 0x80, 0x00))
  end
end

class DependencyObject
  def name=(value)
    self.set_value(FrameworkElement.NameProperty, value.to_clr_string)
  end
end

class UIElement
  alias_method :old_render_transform_origin=, :render_transform_origin=
  def render_transform_origin=(point)
    self.old_render_transform_origin = Point.new(point.first, point.last)
  end
end

class FrameworkElement
  def canvas_top=(value)
    Canvas.set_top(self, value)
  end

  def canvas_left=(value)
    Canvas.set_left(self, value)
  end

  alias_method :old_margin=, :margin=
  def margin=(value)
    self.old_margin = Thickness.new *value
  end

  def method_missing(m, *args)
    super
  rescue => e
    element = find_name(m.to_s.to_clr_string)
    return element unless element.nil?
    raise e
  end
end

class Image
  alias_method :old_source=, :source=
  def source=(value)
    if value.is_a? BitmapImage
      self.old_source = value
    elsif value.is_a? String
      self.old_source = BitmapImage.new(Uri.new(value))
    elsif value.is_a? ClrString
      self.old_source = BitmapImage.new(Uri.new(value.to_s))
    else
      raise "Image.source must be a BitmapImage or a string type"
    end
  end
end

class DoubleKeyFrame
  alias_method :old_key_time=, :key_time=
  def key_time=(time_span)
    self.old_key_time = KeyTime.from_time_span(TimeSpan.parse(time_span))
  end
end

class SplineDoubleKeyFrame
  alias_method :old_key_spline=, :key_spline=
  def key_spline=(data)
    self.old_key_spline = KeySpline.new *data
  end
end

class TextBlock
  alias_method :old_font_family=, :font_family=
  def font_family=(value)
    self.old_font_family = FontFamily.new(value)
  end
end
