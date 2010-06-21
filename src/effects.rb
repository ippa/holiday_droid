class Effect < GameObject
  traits :effect, :velocity
  
  def initialize(options = {})
    super
    @amount = (options[:amount] || 5).to_i - 1
    @child = options[:child]
    self.size = options[:size] || [50, 50]
    
    @amount.times { self.class.create(options.merge(:child => true)) } unless @child
  end

end

class SmokePuff < Effect
  def setup
    @image = Image["circle.png"]
    self.scale_rate = rand/100
    self.alpha = 70
    self.fade_rate = -4
    self.velocity = rand-0.5, rand-0.5
  end
  
  def update
    destroy if  self.alpha == 0
  end
end


