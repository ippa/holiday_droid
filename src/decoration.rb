class PuffText < Text
  traits :timer, :effect, :velocity

  def initialize(text, options = {})    
    super(text, :height => 40, :rotation_center => :center, :x => options[:from].x, :y => 400)
    puff_effect
  end
  
  #def setup
  #  self.height = 40
  #  puff_effect
  #end

  def puff_effect
    self.scale_rate = 0.005
    self.fade_rate = -1
    self.velocity_y = -1
    after(2000) { destroy }
  end
end
