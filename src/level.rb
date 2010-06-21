class Level < GameState
  traits :viewport, :timer
  
  def initialize(options = {})
    super
    
    self.input = { :escape => :exit, :e => :edit }
    self.viewport.game_area = [0, 0, 6000, 1000]    
    @file = File.join(ROOT, "levels", self.filename + ".yml")
    load_game_objects(:file => @file, :debug => DEBUG)
    
    @droid = Droid.create(:x => 100, :y => 500)
    
    self.viewport.lag = 0.95
    
    @saved_x, @saved_y = [100, 300]
    every(5000) { save_player_position }
  end
  
  def edit
    push_game_state GameStates::Edit.new(:file => @file, :grid => [16,16], :except => [Droid], :debug => true)
  end
  
  def restore_player_position
    @droid.x, @droid.y = @saved_x, @saved_y
  end
  
  def save_player_position
    @saved_x, @saved_y = @droid.x, @droid.y   if @droid.collidable && !@jumping
  end

  def update
    #
    # VIEWPORT SCIENCE
    #
    off = (@droid.last_direction == :right) ? 200 : -200
    self.viewport.x_target = @droid.x - $window.width/2 + off
    self.viewport.y_target = @droid.y - $window.height/2 - 200
    
    #
    # COLLECTABLES!
    #
    Collectable.each_collision([@droid]) do |collectable, player|
      collectable.die
      wav = "#{collectable.filename}.wav"
      wav = "collectable.wav"
      Sound[wav].play if Sound[wav]
      PuffText.create("#{collectable.title} <i>+#{collectable.score}</i>", :from => collectable)
    end
    
    #
    # ENEMIES!
    #
    Enemy.each_collision([@droid]) do |enemy, player|
      if player.velocity_y >= 20
        player.y = enemy.bb.top
        enemy.squash
        Sound["attack.wav"].play(0.6)
      elsif player.velocity_y > 2
        player.y = enemy.bb.top
        player.jumps = 0
        player.jump
        enemy.die
        Sound["attack.wav"].play(0.4)
      else
        player.die
        Sound["hurt.wav"].play(0.5)
      end
    end

    $window.caption = "#{@droid.x.to_i}/#{@droid.y.to_i} - viewport x/y: #{self.viewport.x.to_i}/#{self.viewport.y.to_i} - FPS: #{$window.fps}"
    super
  end
  
  def first_terrain_collision(object)
    object.each_collision(@terrain_class.all) do |me, block|
      return block
    end
    nil
  end
end


#
# AT THE BEACH
#
class Beach < Level
  def setup
    @terrain_class = BeachBlock
  end
  
  def draw
    fill_gradient(:from => Color::BLUE, :to => Color::CYAN)
    super
  end
  
  def update
    super
    
    MovingEnemy.inside_viewport.each do |enemy| 
      enemy.unpause! 
    
      if block = first_terrain_collision(enemy)
        enemy.velocity_y = -enemy.velocity_y
        enemy.y += enemy.velocity_y
      end
    end
  end
end


#
# THE GREAT OUTDOORS
#
class Outdoor < Level
  def setup
    @terrain_class = Dirt
  end
end

#
# THE FACTORY
#
class Factory < Level
  def setup
    @terrain_class = BlackBlock
    
    # Reverse the cog wheels in relation to eachother
    CogWheel.each_collision(CogWheel) do |cog_wheel, cog_wheel_2|
      cog_wheel_2.angle_velocity = -cog_wheel.angle_velocity
    end    
  end
  
  def update
    super
    
    FireBall.each_collision(@terrain_blocks) do |fire_ball, block|
      fire_ball.destroy
    end
    
    # Makes all saw pendle up and down between Y-coordinate 1000 - 1500
    # TODO: Not a very flexible sollution, how about setting out circle,rects,lines in editor..
    # .. when then can be used for this kind of stuff?
    
    Saw.all.select {|saw| saw.y < 1300 || saw.y > 1550 }.each do |saw|
      saw.velocity_y = -saw.velocity_y
      saw.y += saw.velocity_y * saw.factor_y 
    end

    @droid.each_collision(FireBall, Saw) do |player, evil_object|
      player.die
    end
    
  end
end
