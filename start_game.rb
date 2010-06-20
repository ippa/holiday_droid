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
    super(1000,800)
    p Gosu::VERSION
  end
  
  def setup
    retrofy
    
    self.factor = 1
    
    #push_game_state(Outdoor)
    
    push_game_state(Beach.new)
    #push_game_state(Intro)
    #push_game_state(Factory)
  end    
end

Game.new.show