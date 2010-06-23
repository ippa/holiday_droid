#
# DROID
#
class Droid < Chingu::GameObject
  trait :bounding_box, :scale => 0.8, :debug => false
  traits :timer, :collision_detection , :timer, :velocity
  
  attr_reader :last_direction
  attr_accessor :jumps, :score
  
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
    @score = 0
    @jumps = 0
    @died_at = [0,0]
    
    @successful_attacks = {}
    @attack_descs = {}
    @attack_descs[3] = "Kill streak"
    @attack_descs[4] = "Serial killah"
    @attack_descs[5] = "Robocop"
    @attack_descs[6] = "Gort"
    @attack_descs[7] = "Terminator"
    @attack_descs[8] = "ED 209"
    @attack_descs[9] = "Hal 9000"
    @attack_descs[10] = "Megatron"
    
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
  
  def on_top_of?(object)
    self.previous_y < object.bb.top
  end
  
  def die
    self.collidable = false
    @color = Color::RED
    @died_at = [self.x, self.y]
    between(1,600) { self.scale += 0.2; self.alpha -= 5; }.then { resurrect }
    Sound["hurt.wav"].play(0.3)
    self.velocity_x = -4
    self.velocity_y = -3
  end
  
  def successfull_attack_on(enemy)
    self.y = enemy.bb.top
    
    if self.velocity_y >= 20        
      enemy.squash
      Sound["attack.wav"].play(0.4)
    elsif self.velocity_y > 2
      self.jumps = 0
      self.jump
      enemy.die
      Sound["attack.wav"].play(0.3)
    end
    
    PuffText.create("#{enemy.title}    <b>+#{enemy.score}</b>")
    self.score += enemy.score
    
    @successful_attacks[enemy.class] ||= 0
    @successful_attacks[enemy.class] += 1
  end
    
  def resurrect
    self.velocity_x = 0
    self.velocity_y = 0
    self.x, self.y = @died_at
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
    Sound["jump.wav"].play(0.2)
    @animation = @animations[:up]
  end
  
  def move(x,y)
    @last_direction = x > 0 ? :right : :left
    @x += x
    @x = previous_x   if game_state.first_terrain_collision(self)
  end
  
  def land
    if self.velocity_y > 15
      SmokePuff.create(:x => self.x, :y => self.y, :size => [self.factor*10, self.factor*10],:amount => self.velocity_y/5)
      Sound["land.wav"].play(0.05 * self.velocity_y / 10)   if self.velocity_y >= 20
    end
    @jumps = 0
    
    credit_successful_attacks
  end
    
  def credit_successful_attacks
    @successful_attacks.each do |key, value|
      if string = @attack_descs[value]
        @attack_descs[value]
        string2 = "#{key.to_s} x #{value}"
        score = value.to_i * key.new.score * 2
        self.score += score
        
        PuffText.create("<b>#{string}!</b>", :size => 50, :y => 400, :color => Gosu::Color::RED )
        PuffText.create("<b>#{string2}</b>    +#{score}", :size => 30, :y => 450)
        Sound["streak.wav"].play(0.3)
      end
    end
    @successful_attacks.clear
  end
  
  def update    
    @image = @animation.next
    
    if block = game_state.first_terrain_collision(self)
      if self.velocity_y < 0
        self.y = block.bb.bottom + self.height
      else
        self.y = block.bb.top-1
        land
      end
      self.velocity_y = 0      
    end
    
    # puts "#{@x} != #{@previous_x} || #{@y} != #{@previous_y}"
    @animation = @animations[:scan] unless @x != @previous_x
  end
end
