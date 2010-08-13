class Collectable < GameObject
  traits :timer, :effect, :velocity, :collision_detection
  trait :bounding_box
  
  attr_reader :title, :score

  def die 
    wav = "#{filename}.wav"
    wav = "collectable.wav"
    Sound[wav].play(0.3) if Sound[wav]
    
    puff_effect
  end

  def puff_effect
    self.collidable = false # Stops further collisiondetection
    self.rotation_rate = 5
    self.scale_rate = 0.03
    self.fade_rate = -3
    self.velocity_y = -2
    after(1000) { destroy }
  end
end

class Battery < Collectable
  def setup
    @image = Image["battery.png"]
    @title = "sparkling fresh battery acid"
    @score = 1000
    cache_bounding_box
  end
end

class SunOil < Collectable
  def setup
    @image = Image["sunoil.bmp"]
    @title = "Tanned like the jersey-shore cast"
    @score = 200
    cache_bounding_box
  end
end

class Melon < Collectable
  def setup
    @image = Image["melon.bmp"]
    @title = "Fresh Watermelon"
    @score = 100
    cache_bounding_box
  end
end

class Coin < Collectable
  def setup
    @image = Image["coin.bmp"]
    @title = "Cash is king"
    @score = 300
    self.rotation_center = :top_left
    cache_bounding_box
  end
end

class Drink < Collectable
  def setup
    @animation = Animation.new(:file => "drink.bmp", :size => [5,9])
    @image = @animation.first
    @title = "frozen margarita"
    @score = 100
    cache_bounding_box
  end
  
  def update
    @image = @animation.next
  end
end