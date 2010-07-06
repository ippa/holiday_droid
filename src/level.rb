class Level < GameState
  traits :viewport, :timer
  attr_reader :player
  
  def initialize(options = {})
    super
    
    self.input = { :escape => :exit, :e => :edit }
    self.viewport.game_area = [0, 0, 6000, 1000]    
    @file = File.join(ROOT, "levels", self.filename + ".yml")
    load_game_objects(:file => @file, :debug => DEBUG)
    puts "blocks: " + Block.size.to_s
    puts "enemies:" + Enemy.size.to_s
    
    @lookup_map = GameObjectMap.new(:game_objects => Block.all, :grid => [32, 32], :debug => false)
    
    @player = Droid.create(:x => 32, :y => 500)
    @score = Text.create("Score: #{@player.score}", :x => 5, :y => 5, :size => 20, :rotation_center => :top_left)
    
    self.viewport.lag = 0.95
    
    @saved_x, @saved_y = [100, 300]
    every(5000) { save_player_position }
  end
  
  def edit
    push_game_state GameStates::Edit.new(:file => @file, :grid => [32,32], :except => [Droid], :debug => false)
  end
  
  def restore_player_position
    @player.x, @player.y = @saved_x, @saved_y
  end
  
  def save_player_position
    @saved_x, @saved_y = @player.x, @player.y   if @player.collidable && !@jumping
  end

  def update
    #
    # VIEWPORT SCIENCE
    #
    off = (@player.last_direction == :right) ? 200 : -200
    self.viewport.x_target = @player.x - $window.width/2 + off
    self.viewport.y_target = @player.y - $window.height/2 - 200
    
    #
    # COLLECTABLES!
    #
    Collectable.each_collision(@player) do |collectable, player|
      collectable.die
      PuffText.create("#{collectable.title}    <b>+#{collectable.score}</b>")
      @player.score += collectable.score
    end
    
    #
    # ENEMIES!
    #
    Enemy.each_collision(@player) do |enemy, player|
      
      # Is player comming from above, planting his feed in enemies head? :)
      if player.on_top_of?(enemy)
        enemy.hit(20)   if @player.velocity_y >= 20
        enemy.hit(10)   if @player.velocity_y >= 2
  
        # Bounce if: enemy is still alive or if we're doing a non-highspeed jump
        @player.bounce_on(enemy)  if enemy.alive? || @player.velocity_y < 20
        
        if enemy.dead?
          @player.successfull_attack_on(enemy)
          PuffText.create("#{enemy.title}    <b>+#{enemy.score}</b>")
          @player.score += enemy.score
        end
      else
        player.die
        enemy.die
      end
    end

    @score.text = "Score: #{@player.score}"
    @score.x = viewport.x + 5
    $window.caption = "#{@player.x.to_i}/#{@player.y.to_i} - viewport x/y: #{self.viewport.x.to_i}/#{self.viewport.y.to_i} - FPS: #{$window.fps}"
    
    super
  end
    
  def first_terrain_collision(object)
    @lookup_map.from_game_object(object)   if object.collidable
    #object.each_collision(Block) do |me, block|
    #  return block
    #end
    #nil
  end
end

#
# AT THE BEACH
#
class Beach < Level 
  def draw
    fill_gradient(:from => Color::BLUE, :to => Color::CYAN)
    super
  end
  
  def update
    super
    
    MovingEnemy.inside_viewport.each { |enemy| enemy.unpause! }
  end
end


#
# THE GREAT OUTDOORS
#
class Outdoor < Level
end

#
# THE FACTORY
#
class Factory < Level
  def setup
   
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

    @player.each_collision(FireBall, Saw) do |player, evil_object|
      player.die
    end
    
  end
end
