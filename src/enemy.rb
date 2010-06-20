#
# A FIREBALL
#
class FireBall < GameObject
  traits :velocity, :collision_detection
  trait :bounding_circle, :scale => 0.7
  
  def setup
    @animation = Animation.new(:file => "fireball.png", :size => [32,32], :delay => 20)
    @image = @animation.first
    self.mode = :additive
    self.factor = 3
    self.velocity_y = 1
    self.zorder = 200
    self.rotation_center = :center
  end
  
  def update
    @image = @animation.next
    @angle += 2
  end
end

#
# COG WHEEL
#
class CogWheel < GameObject
  traits :bounding_circle, :collision_detection, :timer
  attr_accessor :angle_velocity
  
  def setup    
    @image = Image["cog_wheel.png"]
    @angle_velocity = 1 / self.factor_x
  end
  
  def update
    self.angle += @angle_velocity
  end
end

#
# SAW
#
class Saw < GameObject
  traits :bounding_circle, :collision_detection, :timer, :velocity
  attr_accessor :angle_velocity
  
  def setup    
    @image = Image["saw.png"]
    @angle_velocity = 3.0 / self.factor_x.to_f
    self.velocity_y = 1.0 / self.factor_x.to_f
  end
  
  def update
    self.angle += @angle_velocity
  end
end

