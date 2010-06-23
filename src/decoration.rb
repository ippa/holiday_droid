class PuffText < Text
  traits :timer, :effect, :velocity

  def initialize(text, options = {})    
    super(text, {:y => 400, :size => 20, :center_x => 0.5}.merge(options))
    self.x = ($window.width / 2) + game_state.viewport.x
    self.rotation_center = :center
    puff_effect
  end
  
  def puff_effect
    self.scale_rate = 0.01
    self.fade_rate = -1
    self.velocity_y = -2
    after(3000) { destroy }
  end
end
