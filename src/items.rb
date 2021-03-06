
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
    FireBall.create(:x => self.bb.centerx - rand(10), :y => self.bb.bottom - rand(10))
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

class BouncePad < GameObject
  trait :bounding_box, :scale => 0.75
  traits :collision_detection, :timer
  
  def setup
    @image = Image["bounce_pad.png"]
    cache_bounding_box
  end
  
  def hit_by(object)
    object.velocity_x -= 3 if object.bb.left < self.bb.left
    object.velocity_x += 3 if object.bb.right > self.bb.right
    #after(400) { object.velocity_x = 0}
    
    object.velocity_y = -20
    Sound["boink.wav"].play(0.4)
  end
end

#
# BLOCK, our basic level building block
#
class Block < GameObject
  traits :bounding_box, :collision_detection
  
  def setup
    @image = Image["#{self.filename}.png"]
    self.rotation_center = :top_left
  end
  
  def self.solid
    all.select { |block| block.alpha == 255 }
  end
  
  def hit(power)
  end

  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end
end

class BeachBlock < Block; end
class BlackBlock < Block; end
class DirtBlock < Block; end

#
# Broken Blocks. Disapears when player is jumping hard on them.
#
class BrokenBlock < Block
  def hit(power)
    if power > 15
      self.destroy  
      self.parent.lookup_map.clear_game_object(self)
    end
  end  
end

class BrokenBeachBlock < BrokenBlock; end
class BrokenDirtBlock < BrokenBlock; end