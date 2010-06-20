class Level < GameState
  traits :viewport, :timer
  
  def initialize(options = {})
    super
    
    self.input = { :escape => :exit, :e => :edit }
    self.viewport.game_area = [0, 0, 6000, 1000]    
    load_game_objects(:debug => DEBUG)
    
    @droid = Droid.create(:x => 100, :y => 500)
    
    self.viewport.lag = 0.95
    
    @saved_x, @saved_y = [100, 300]
    every(5000) { save_player_position }
  end
  
  def edit
    push_game_state GameStates::Edit.new(:grid => [16,16], :except => [Droid], :debug => true)
  end
  
  def restore_player_position
    @droid.x, @droid.y = @saved_x, @saved_y
  end
  
  def save_player_position
    @saved_x, @saved_y = @droid.x, @droid.y   if @droid.collidable && !@jumping
  end

  def update    
    off = (@droid.last_direction == :right) ? 200 : -200
    self.viewport.x_target = @droid.x - $window.width/2 + off
    self.viewport.y_target = @droid.y - $window.height/2 - 200
    
    @droid.each_collision(Battery) do |player, collectable|
      player.level_up
      collectable.die
      PuffText.create("#{collectable.title} <i>+#{collectable.score}</i>", :from => collectable)
    end

    @droid.each_collision(Drink) do |player, collectable|
      collectable.die
      PuffText.create("#{collectable.title} <u>+#{collectable.score}</u>", :from => collectable)
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
    
    Ball.inside_viewport.each do |ball| 
      ball.unpause! 
      if block = first_terrain_collision(ball)
        ball.velocity_y = -ball.velocity_y
        ball.y += ball.velocity_y
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
