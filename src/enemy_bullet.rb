class EnemyBullet < GameObject
  traits :velocity, :collision_detection
end
  
#
# A FIREBALL
#
class FireBall < EnemyBullet
  trait :bounding_circle, :scale => 0.7
  
  def setup
    @animation = Animation.new(:file => "fireball.png", :size => [32,32], :delay => 20)
    @image = @animation.first
    self.mode = :additive
    self.factor = 3
    self.velocity_y = 1
    self.zorder = 200
    self.rotation_center = :center
  end
  
  def die
    destroy
  end
  
  def update
    @image = @animation.next
    @angle += 2
  end
end
