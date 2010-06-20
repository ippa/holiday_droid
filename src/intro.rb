class Intro < GameState
  trait :timer
  
  def setup
    pop_game_state
    
    self.input = { [:space, :esc] => :exit }
    @strings = [
      "At last... some peace and quiet after 10 years without a vacation.",     # 0
      "Just kick back, relax and work on my tan. I've really deserved this.",   # 4
      "* BOOM BOOM BOOM BOOM *",                                                # 8
      "Hey, keep that music down will ya?",                                     # 12
      "* CAW CAAA-CAAA CAAAW * ",                                               # 16
      "...God loved the birds and invented trees. Robot loved the birds and built cages.", # 20
      "Mmm, this drink is really tasty",  # 24
      "",                                 # 28
      "..."                               # 32
    ]
        
    GameObject.create(:image => "beach.bmp", :x => 0, :y => $window.height, :rotation_center => :bottom_left, :scale => 5)
    
    anim = Animation.new(:file => "beach_droid.bmp", :size => [11,18])
    @droid = GameObject.create(:x => 402, :y => $window.height-200, :animation => anim, :image => anim.first, :scale => 15)    
    @drink = Drink.create(:x => 400, :y => $window.height-200, :scale => 15)    
    
    @story = Text.create(@strings.shift, :x => 100, :y => 30, :size => 40, :max_width => 400, :color => Color::WHITE)
    every(4000) { @story.text = @strings.shift }
    after(7 * 4000) { Ball.create(:x => $window.width, :y => 300, :velocity_x => -6, :scale => 5)}
  end
  
  def update
    fill_gradient(:from => Color::CYAN, :to => Color::BLUE)
    
    if Ball.all.first && Ball.all.first.x < @drink.x # Ball hits the drink, robot gets crazy up in this mtfckr.
      if @droid.angle == 0
        @droid.image = @droid.options[:animation].next
        @droid.angle = -90
        after(4000) { @droid.image = @droid.options[:animation].next; }
      end
    end
      
    super
  end
end
