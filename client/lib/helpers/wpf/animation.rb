class Animation::Base
  def random_name
    #"animation#{Random.new.next(1000000)}"
    @count ||= 0
    "animation#{@count}"
  end

  def obj
    @obj
  end
end

class BounceAnimation < Animation::Base
  def initialize(scale_transform_element)
    @name = random_name
    # NOTE that we don't need to name the storyboard element anymore! - can 
    # do away with name property too!
    @obj = Wpf.build(Storyboard, :target_name => scale_transform_element) do 
      add(DoubleAnimationUsingKeyFrames, :begin_time=>'00:00:00', :target_property => "ScaleX") do
        add SplineDoubleKeyFrame, :key_time => '00:00:00.0', :value => 0.200
        add SplineDoubleKeyFrame, :key_time => '00:00:00.2', :value => 0.935
        add SplineDoubleKeyFrame, :key_time => '00:00:00.3', :value => 0.852
        add SplineDoubleKeyFrame, :key_time => '00:00:00.4', :value => 0.935
      end
      add(DoubleAnimationUsingKeyFrames, :begin_time=>'00:00:00', :target_property => "ScaleY") do
        add SplineDoubleKeyFrame, :key_time => '00:00:00.0', :value => 0.200
        add SplineDoubleKeyFrame, :key_time => '00:00:00.2', :value => 0.935
        add SplineDoubleKeyFrame, :key_time => '00:00:00.3', :value => 0.852
        add SplineDoubleKeyFrame, :key_time => '00:00:00.4', :value => 0.935
      end
    end
  end

  # TODO: cannot attr_reader :name
  def name
    @name
  end
end