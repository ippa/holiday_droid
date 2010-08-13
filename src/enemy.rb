class Enemy < GameObject
  traits :velocity, :timer, :effect, :collision_detection
  trait :bounding_box, :debug => false
  attr_reader :title, :score
  
  def initialize(options = {})
    @image ||= Image["#{self.filename}.bmp"] rescue Image["#{self.filename}.png"]
    @title = "- title needed -"
    @energy = 10
    @status = :default
    super
    self.rotation_center = :bottom_center
  end
  
  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end
      
  def dead?;  @status == :dead;  end
  def alive?; @status != :dead;  end

  def hit(energy)
    @energy -= energy
    Sound["attack.wav"].play(0.4)
    during(50) { self.mode = :additive }.then { self.mode = :default }
    
    if @energy <= -10
      return squash
    elsif @energy <= 0
      return die
    end
      
    return false
  end

  def squash
    @status = :dead
    self.collidable = false
    self.rotation_rate = -5
    self.scale_rate = 0.02
    self.factor_x *= 1.5
    self.factor_y *= 1.3
    self.velocity_y = 2
    self.velocity_x = 0
    self.acceleration_y = 0.5
    
    every(200) { self.mode = (self.mode == :default) ? :additive : :default }
    after(2000) { destroy }
  end
    
  def die
    @status = :dead
    self.collidable = false
    self.rotation_rate = -1
    self.scale_rate = 0.1
    self.factor_x *= 1.2
    self.factor_y *= 1.2    
    self.velocity_y = -2
    self.velocity_x = 4
    self.acceleration_y = 0.5
    
    every(100) { self.mode = (self.mode == :default) ? :additive : :default }
    after(2000) { destroy }
  end
  
  def update
    @image = @animation.next  if @animation
    self.factor_x = (self.velocity_x < 0) ? self.factor_x.abs : -self.factor_x.abs
  end
  
end
  
#
# Moving enemies are paused until they get into the viewport
#
class MovingEnemy < Enemy
  
  def initialize(options = {})
    super
    self.acceleration_y = 0.5
  end
  
  def bounce
    self.velocity_y = -self.velocity_y
    self.y += self.velocity_y
  end  
  
  def turn
    self.velocity_x = -self.velocity_x
    self.x += self.velocity_x + 1
  end
  
  # This overrides the move() trait velocity adds and calls
  # Add invidual X-axis / Y-axis collision detection 
  def move(x, y)
    if y != 0
      @y += y
      bounce  if game_state.first_terrain_collision(self)
    end
    
    if x != 0
      @x += x
      turn    if game_state.first_terrain_collision(self)
    end
  end
  
end

class Fish < MovingEnemy
  def setup
    @animation = Animation.new(:file => "fish.bmp", :delay => 50, :size => [15,9])
    @image = @animation.first
    self.velocity_x = -2
    @title = "floppy fish"
    @score = 100
    @energy = 10
  end
end

class Crab < MovingEnemy
  def setup
    @animation = Animation.new(:file => "crab.bmp", :delay => 100, :size => [15,9])
    @image = @animation.first
    self.velocity_x = -1.5
    @title = "crab killah"
    @score = 300
    @energy = 20
  end
end

class Snail < MovingEnemy
  def setup
    @animation = Animation.new(:file => "snail.bmp", :delay => 200, :size => [13,12])
    @image = @animation.first
    self.velocity_x = -1
    @title = "snail slainer"
    @score = 1000
    @energy = 30
  end
end

class Seagull < MovingEnemy
  def setup
    @animation = Animation.new(:file => "seagull.bmp", :delay => 100, :size => [15,8])
    @image = @animation.first
    @title = "no more Caw-Caw!"
    @score = 850
    @energy = 20
    
    self.acceleration_y = 0
  end  
end

class BeachBoss < MovingEnemy
  def setup
    @animation = Animation.new(:file => "beach_boss.bmp", :delay => 100, :size => [17,32])
    @image = @animation.first
    self.velocity_x = 0
    @title = "overtanned guido"
    @score = 10000
    @energy = 300
  end
  
  def update
  end
end

class Ball < MovingEnemy
  def setup
    self.velocity_x = -4
    @title = "A ball"
    @score = 400
    @energy = 10
  end  
end


class BeachBall < MovingEnemy
  def setup
    @title = "annoying beachball"
    @score = 400
    @energy = 10
  end  
end
