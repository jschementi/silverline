include System::Windows::Media
include System::Windows::Media::Animation
include System::Windows::Media::Imaging
include System::Windows::Controls

module Wpf
  module Builders
    def name_collector
      @___name_collector_ 
    end

    def [](name)
      name_collector[name]
    end

    def inject_names(obj)
      name_collector.each_pair { |k, v| obj.instance_variable_set("@#{k}".to_sym, v) }
    end

    def evaluate_properties(obj, args, &b) 
      obj.instance_variable_set(:@___name_collector_, name_collector)

      args.each_pair do |k, v| 
        if k == :name 
          name_collector[v] = obj
        end
        obj.send :"#{k.to_s}=", v
      end
      
      if obj.respond_to? :name
        name_collector[obj.name] = obj unless obj.name.nil?
      end

      obj
    end

    def add_object_to_name_collector(collection, obj, args = {}, &b)
      obj = evaluate_properties(obj, args, &b)
      obj.instance_eval(&b) unless b.nil?
      collection.add obj
      obj
    end

    def add_class_to_name_collector(collection, klass, args = {}, &b)
      obj = evaluate_properties(klass.new, args, &b)
      obj.instance_eval(&b) unless b.nil?
      collection.add obj
      obj
    end

    def assign_to_name_collector(property, klass, args = {}, &b) 
      obj = evaluate_properties(klass.new, args, &b)
      obj.instance_eval(&b) unless b.nil?
      self.send property, obj
      obj
    end
  end

  def self.build(klass, args = {}, &b)
    obj = klass.new
    obj.instance_variable_set(:@___name_collector_, {})

    args.each_pair do |k, v| 
      if k == :name 
        obj.name_collector[v] = obj 
      end
      obj.send :"#{k.to_s}=", v
    end

    obj.instance_eval(&b) if b != nil
    obj
  end
end

class Timeline
  include Wpf::Builders

  alias_method :old_begin_time=, :begin_time=
  def begin_time=(time_span)
    self.old_begin_time = TimeSpan.parse(time_span)
  end

  def add(klass, args = {}, &b)
    add_class_to_name_collector(key_frames, klass, args, &b)
  end

  def target_property=(property)
    Storyboard.set_target_property(self, property)
  end

  def target_name=(name)
    Storyboard.set_target_name(self, name)
  end
end

class TransformGroup
  include Wpf::Builders

  def add(klass, args = {}, &b)
    add_class_to_name_collector(children, klass, args, &b)
  end
end

class Storyboard
  include Wpf::Builders

  def add(klass, args = {}, &b)
    add_class_to_name_collector(children, klass, args, &b)
  end
end

class Panel
  include Wpf::Builders

  def add(klass, args = {}, &b)
    add_class_to_name_collector(children, klass, args, &b)
  end

  def add_name(name, obj)
    name_collector[name] = obj
  end

  def add_obj(obj)
    add_object_to_name_collector(children, obj)
  end

  alias_method :old_background=, :background=
  def background=(color)
    self.old_background = case color
    when :black
      Brushes.black
    when :white
      Brushes.white
    when :green
      Brushes.green
    end
  end
end

