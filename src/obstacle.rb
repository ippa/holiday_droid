class Obstacle < GameObject
  traits :collision_detection
end

#
# SAW
#
class Saw < Obstacle
  traits :bounding_circle, :velocity  
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

class StaticSaw < Saw
  def setup
    super
    self.velocity_y = 0
  end
  
end