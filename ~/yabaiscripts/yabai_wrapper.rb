# frozen_string_literal: true

require 'JSON'
require 'pry-byebug'

class YabaiWrapper
  def initialize; end

  def destroy_non_fullscreen_spaces
    all_displays.each do |display|
      next if display['spaces'].count == 1

      focus_display(display['index'])
      non_fs_spaces = non_fullscreen_spaces(display['index']).sort_by { |x| x['index'] }.reverse
      non_fs_spaces.each do |space|
        if space == non_fs_spaces.last
          label_space(space['index'], '')
          next
        end

        focus_space(space['index'])
        destroy_current_space
      end
    end
  end

  def init_non_fullscreen_spaces
    iterator = 1
    all_displays.each do |display|
      space_on_display = non_fullscreen_spaces(display['index']).first
      focus_space(space_on_display['index'])
      label_space(space_on_display['index'], "s#{iterator}")
      iterator += 1
      create_space
    end
  end

  def non_fullscreen_spaces(index = nil)
    cmd_suffix =
      if index
        " --display #{index}"
      else
        ''
      end
    JSON.parse(`yabai -m query --spaces#{cmd_suffix}`).select { |space| space['native-fullscreen'].zero? }
  end

  def current_display
    JSON.parse(`yabai -m query --displays --display`)
  end

  def all_displays
    JSON.parse(`yabai -m query --displays`)
  end

  def create_space
    `yabai -m space --create`
  end

  def destroy_current_space
    `yabai -m space --destroy`
  end

  def focus_display(index)
    `yabai -m display --focus #{index}`
  end

  def focus_space(identifier)
    # space identifier can be index or label
    `yabai -m space --focus #{identifier}`
  end

  def label_space(index, label)
    `yabai -m space #{index} --label #{label}`
  end

  def move_space_to_display(space_identifier, display_index)
    # space identifier can be index or label
    `yabai -m space #{space_identifier} --display #{display_index}`
  end

  def open_space_on_display(space_label, display_index)
    spaces = non_fullscreen_spaces
    anywhere = spaces.find { |space| space['label'] == space_label }
    unless anywhere
      create_space
      new_spaces = non_fullscreen_spaces
      diff = new_spaces - spaces
      label_space(diff.first['index'], space_label)
      focus_space(space_label)
      return
    end

    on_desired_display = spaces.find { |space| space['label'] == space_label && space['display'] == display_index && space['visible'] == 1 }
    return if on_desired_display&.[]('visible') == 1

    visible_space_on_other_display = spaces.find { |space| space['label'] == space_label && space['display'] != display_index && space['visible'] == 1 }
    if visible_space_on_other_display
      current_visible_space = spaces.find { |space| space['display'] == display_index && space['visible'] == 1 }
      move_space_to_display(space_label, display_index)
      move_space_to_display(current_visible_space['label'], visible_space_on_other_display['display'])
      return
    end

    move_space_to_display(space_label, display_index) unless on_desired_display
    focus_space(space_label)
  end
end
