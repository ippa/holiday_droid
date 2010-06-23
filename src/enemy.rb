class Enemy < GameObject
  traits :velocity, :timer, :effect, :bounding_box, :collision_detection
  
  attr_reader :title, :score
  
  def initialize(options = {})
    @image = Image["#{self.filename}.bmp"]
    @title = "- title needed -"
    
    super
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
    self.acceleration_y = 0.5
    pause!
    
    super
  end
  
  def bounce
    self.velocity_y = -self.velocity_y
  end  
end

class Fish < MovingEnemy
  def setup
    @animation = Animation.new(:file => "fish.bmp", :delay => 50, :size => [15,9])
    @image = @animation.first
    self.velocity_x = -2
    @title = "floppy fish"
    @score = 100
  end
end

class Crab < MovingEnemy
  def setup
    @animation = Animation.new(:file => "crab.bmp", :delay => 100, :size => [15,9])
    @image = @animation.first
    self.velocity_x = -1.5
    @title = "crab killah"
    @score = 300
  end
end

class Snail < MovingEnemy
  def setup
    @animation = Animation.new(:file => "snail.bmp", :delay => 200, :size => [13,12])
    @image = @animation.first
    self.velocity_x = -1
    @title = "Snail Slainer"
    @score = 1000
  end
end

class Seagull < MovingEnemy
  def setup
    @animation = Animation.new(:file => "seagull.bmp", :delay => 100, :size => [15,8])
    @image = @animation.first
    @title = "No more Caw-Caw!"
    @score = 850
    
    self.acceleration_y = 0
  end  
end


class Ball < MovingEnemy
  def setup
    self.velocity_x = -4
    @title = "annoying beachball"
    @score = 400
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

