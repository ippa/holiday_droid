class Enemy < GameObject
  traits :velocity, :timer, :effect, :bounding_box, :collision_detection
  
  def initialize(options = {})
    super
    
    @image = Image["#{self.filename}.bmp"]
    @title = "- title needed -"
  end
  
  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end
    
  def update
    @image = @animation.next  if @animation
  end

  def squash
    self.collidable = false
    self.rotation_rate = -5
    self.scale_rate = 0.02
    self.factor_x *= 2
    self.velocity_y = 2
    self.velocity_x = 0
    self.acceleration_y = 0.5
    every(100) { self.mode = (self.mode == :default) ? :additive : :default }
    after(2000) { destroy }
  end

  def die 
    self.collidable = false
    self.rotation_rate = -1
    self.scale_rate = 0.1
    self.velocity_y = -2
    self.velocity_x = 4
    self.acceleration_y = 0.5
    
    every(100) { self.mode = (self.mode == :default) ? :additive : :default }
    after(2000) { destroy }
  end
  
end
  
#
# Moving enemies are paused until they get into the viewport
#
class MovingEnemy < Enemy
  def initialize(options = {})
    super
    
    self.acceleration_y = 0.5
    pause!
  end
  
  def bounce
    self.velocity_y = -self.velocity_y
  end  
end

class Fish < MovingEnemy
  def setup
    @animation = Animation.new(:file => "fish.bmp", :delay => 40, :size => [15,9])
    @image = @animation.first
    self.velocity_x = -3
    @title = "Kill the fish!"
  end
end

class Crab < MovingEnemy
  def setup
    @animation = Animation.new(:file => "crab.bmp", :delay => 40, :size => [15,9])
    @image = @animation.first
    self.velocity_x = -2
    @title = "Crab Killah"
  end
end

class Ball < MovingEnemy
  def setup
    self.velocity_x = -4
    @title = "an annoying beachball"
  end  
end



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

