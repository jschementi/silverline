render :partial => "clock", :properties => {:type => "Canvas"}

def from_angle(time, divisor = 5, offset = 0)
  ((time / (12.0 * divisor)) * 360) + offset + 180
end

def to_angle(time)
  from_angle(time) + 360
end
d = Time.now
root.hour_animation.from    = from_angle  d.hour, 1, d.minute/2
root.hour_animation.to      = to_angle    d.hour
root.minute_animation.from  = from_angle  d.minute
root.minute_animation.to    = to_angle    d.minute
root.second_animation.from  = from_angle  d.second
root.second_animation.to    = to_angle    d.second
