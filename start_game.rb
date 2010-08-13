#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "../", "chingu", "lib", "chingu")
#require 'chingu'
include Gosu
include Chingu

require_rel 'src/*'
DEBUG = false

class Game < Chingu::Window 
  def initialize
    super(1000,700)
  end
  
  def setup
    retrofy
    
    #Text.font = "media/badankadonk.ttf"
    
    self.factor = 1
        
    #push_game_state(Intro)
    #push_game_state(Factory)
    push_game_state(Outdoor)
    #push_game_state(Beach)
    #puts current_game_state.player.bb.left
    #puts current_game_state.player.bb.right
    #exit
  end    
end

Game.new.show