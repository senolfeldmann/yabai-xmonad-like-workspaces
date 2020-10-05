# frozen_string_literal: true

require 'JSON'
require_relative 'yabai_wrapper'

Yabai = YabaiWrapper.new

current_display_index = Yabai.current_display['index']
Yabai.destroy_non_fullscreen_spaces
Yabai.init_non_fullscreen_spaces
Yabai.focus_display(current_display_index)
