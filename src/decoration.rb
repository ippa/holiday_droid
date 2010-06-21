class PuffText < Text
  traits :timer, :effect, :velocity

  def initialize(text, options = {})    
    super(text, :height => 20, :rotation_center => :center, :x => options[:from].x-200, :y => 400)
    puff_effect
  end
  
  def puff_effect
    self.scale_rate = 0.01
    self.fade_rate = -1
    self.velocity_y = -2
    after(3000) { destroy }
  end
end
