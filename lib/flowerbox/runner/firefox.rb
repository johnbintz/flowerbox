require 'flowerbox/runner/selenium'

class Flowerbox::Runner::Firefox < Flowerbox::Runner::Selenium
  def name
    "Firefox"
  end

  def console_name
    "Firefox".foreground('#d0450b')
  end

  def browser
    Flowerbox.browsers[:firefox] ||= ::Selenium::WebDriver.for(:firefox)
  end
end

