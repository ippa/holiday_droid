#
# DROID
#
class Droid < Chingu::GameObject
  trait :bounding_box, :scale => 0.8, :debug => false
  traits :timer, :collision_detection , :timer, :velocity
  attr_reader :last_direction
  attr_accessor :jumps
  
  def setup
    self.input = {  [:holding_left, :holding_a] => :holding_left, 
                    [:holding_right, :holding_d] => :holding_right,
                    [:down, :s] => :down,
                    [:up, :w] => :jump,
                  }
    
    # Load the full animation from tile-file media/droid.bmp
    @animations = Chingu::Animation.new(:file => "droid_11x15.bmp")
    @animations.frame_names = { :scan => 0..5, :up => 6..7, :down => 8..9, :left => 10..11, :right => 12..13 }
    
    @last_direction = :right
    @animation = @animations[:scan]
    @image = @animation.first
    @speed = 4
    @jumps = 0
    
    self.factor = 4
    self.zorder = 1000
    self.acceleration_y = 0.5
    self.max_velocity = 20
    self.rotation_center = :bottom_center
  end
  
  def level_up
    new_factor = self.factor + 3
    between(1,500) { self.factor += 0.1 }.then { self.factor = new_factor }
  end
  
  def jumping
    @jumps > 0
  end
  
  def die
    self.collidable = false
    @color = Color::RED
    between(1,600) { self.velocity_y = 0; self.scale += 0.2; self.alpha -= 5; }.then { resurrect }
  end
    
  def resurrect
    self.alpha = 255
    self.factor = 3
    self.collidable = true
    @color = Color::WHITE
    game_state.restore_player_position
  end

  def holding_left
    move(-@speed, 0)
    @animation = @animations[:left]
  end

  def holding_right
    move(@speed, 0)
    @animation = @animations[:right]
  end

  def down
    self.velocity_y = 20  if @jumps > 0
    self.velocity_y = 30  if @jumps > 1
    @animation = @animations[:down]
  end

  def jump
    return if @jumps == 2
    SmokePuff.create(:x => self.x, :size => [self.factor*10, self.factor*10], :y => self.y, :amount => 2)  if @jumps == 1
  
    @jumps += 1
    self.velocity_y = -11
    Sound["jump.wav"].play(0.4)
    @animation = @animations[:up]
  end
  
  def move(x,y)
    @last_direction = x > 0 ? :right : :left
    @x += x
    @x = previous_x   if game_state.first_terrain_collision(self)
  end
  
  def update    
    @image = @animation.next
    
    if block = game_state.first_terrain_collision(self)
      if self.velocity_y < 0
        self.y = block.bb.bottom + self.height
      else
        if self.velocity_y > 15
          SmokePuff.create(:x => self.x, :y => self.y, :size => [self.factor*10, self.factor*10],:amount => self.velocity_y/5)
          Sound["land.wav"].play(0.2 * self.velocity_y / 10)   if self.velocity_y >= 20
        end
        @jumps = 0
        self.y = block.bb.top-1
      end
      self.velocity_y = 0      
    end
    
    # puts "#{@x} != #{@previous_x} || #{@y} != #{@previous_y}"
    @animation = @animations[:scan] unless @x != @previous_x
  end
end
