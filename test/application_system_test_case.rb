require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  SCREEN_SIZE = [ 1400, 900 ]

  driven_by :selenium, using: :headless_chrome, screen_size: SCREEN_SIZE

  # The browser window is shared between tests, so undo any resize a test made.
  teardown { page.current_window.resize_to(*SCREEN_SIZE) }

  private

  # The element's position and size on screen, as a hash with "top", "bottom", "left", "right", "width" and "height".
  def rect(selector)
    evaluate_script("document.querySelector(#{selector.to_json}).getBoundingClientRect().toJSON()")
  end
end
