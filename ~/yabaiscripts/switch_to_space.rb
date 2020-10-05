# frozen_string_literal: true

require 'JSON'
require_relative 'yabai_wrapper'

Yabai = YabaiWrapper.new

current_display_index = Yabai.current_display['index']
Yabai.open_space_on_display(ARGV[0], current_display_index)
Yabai.focus_display(current_display_index)
