
#
# TUBE
#
class Tube < GameObject
  traits :bounding_box, :timer
  def setup
    @image = Image["tube.png"]
    every(3000)  { fire }
    cache_bounding_box
  end
  
  def fire
    return if game_state.viewport.outside?(self.bb.centerx, self.bb.bottom)
    FireBall.create(:x => self.bb.centerx - rand(10), :y => self.bb.bottom - rand(10))
  end
end


#
# CLOUD
#
class Cloud < GameObject
  traits :bounding_box, :velocity
  def setup
    @image = Image["cloud.png"]
    cache_bounding_box
    self.velocity_x = rand - 0.5
  end  
end


class MovingObject < GameObject
  traits :velocity, :bounding_box, :collision_detection
  
  def initialize(options = {})
    super
    
    @image = Image["#{self.filename}.bmp"]
    self.acceleration_y = 0.5
    pause!
  end
  
  def self.solid
    all.select { |block| block.alpha == 255 }
  end

  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end
  
  def title
    "-new title needed-"
  end
end


class Ball < MovingObject
  
  def setup
    self.velocity_x = -4
  end
  
  def bounce
    self.velocity_y = -self.velocity_y
  end
  
  def title
    "an annoying beachball"
  end
end

#
# BLOCK, our basic level building block
#
class Block < GameObject
  traits :bounding_box, :collision_detection
  
  def setup
    @image = Image["#{self.filename}.png"]
  end
  
  def self.solid
    all.select { |block| block.alpha == 255 }
  end

  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end
end

class BeachBlock < Block; end
class BlackBlock < Block; end
class Dirt < Block; end