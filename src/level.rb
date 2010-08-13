class Level < GameState
  traits :viewport, :timer
  attr_reader :player, :lookup_map
  
  def initialize(options = {})
    super
    
    self.input = { :escape => :exit, :e => :edit }
    self.viewport.game_area = [0, 0, 10000, 3000]    
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
    push_game_state GameStates::Edit.new(:file => @file, :grid => [32,32], :except => [Droid, Cloud, SmokePuff, Battery], :debug => false)
  end
  
  def restore_player_position
    @player.x, @player.y = @saved_x, @saved_y
  end
  
  def save_player_position
    @saved_x, @saved_y = @player.x, @player.y   if @player.collidable && !@jumping
  end

  def update
    super
    
    #
    # VIEWPORT SCIENCE
    #
    off = (@player.last_direction == :right) ? 200 : -200
    self.viewport.x_target = @player.x - $window.width/2 + off
    self.viewport.y_target = @player.y - $window.height/2 - 100
    
    #
    # COLLECTABLES! (stuff that can be picked up for score)
    #
    Collectable.each_collision(@player) do |collectable, player|
      collectable.die
      PuffText.create("#{collectable.title}    <b>+#{collectable.score}</b>")
      @player.score += collectable.score
    end
    
    #
    # ENEMY BULLETS! (destructable items, usually moving across the screen)
    #
    EnemyBullet.each_collision(@player) do |enemy_bullet, player|
      player.die
      enemy_bullet.destroy
    end
    
    EnemyBullet.all.each do |enemy_bullet|
      enemy_bullet.destroy if @lookup_map.at(enemy_bullet.x, enemy_bullet.y)
    end
    
    BouncePad.each_collision(@player) do |bounce_pad, player|
      bounce_pad.hit_by(player)
    end
    
    #
    # OBSTACLES (nondestructable player-killing things)
    #
    Obstacle.each_collision(@player) do |obstacle, player|
      player.die
    end

    
    #
    # ENEMIES! (can kill, can be killed, can bounce on)
    #
    Enemy.each_collision(@player) do |enemy, player|
      
      # Is player comming from above, planting his feet in an enemies head? :)
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
    $window.caption = "#{@player.x.to_i}/#{@player.y.to_i} velocity x/y: #{@player.velocity_x.to_i}/#{@player.velocity_y.to_i} - viewport x/y: #{self.viewport.x.to_i}/#{self.viewport.y.to_i} - FPS: #{$window.fps}"
  end
    
  def first_terrain_collision(object)
    @lookup_map.from_game_object(object)   if object.collidable
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
end
class Beach2 < Beach; end
class Beach3 < Beach; end


#
# THE GREAT OUTDOORS
#
class Outdoor < Level
  def draw
    fill_gradient(:from => Color::BLUE, :to => Color::CYAN)
    super
  end
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
    
    Saw.all.select {|saw| @lookup_map.at(saw.x, saw.y)}.each do |saw|
      saw.velocity_y = -saw.velocity_y
      saw.y += saw.velocity_y * saw.factor_y
    end
    
  end
end

class Factory2 < Factory; end
class Factory3 < Factory; end
