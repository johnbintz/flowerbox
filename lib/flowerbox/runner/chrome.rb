class Flowerbox::Runner::Chrome < Flowerbox::Runner::Selenium
  def name
    "Chrome"
  end

  def console_name
    "C".foreground('#4f97d1') +
    "h".foreground('#ec5244') +
    "r".foreground('#fdd901') +
    "o".foreground('#4f97d1') +
    "m".foreground('#5cb15b') +
    "e".foreground('#ec5244')
  end

  def browser
    @browser ||= ::Selenium::WebDriver.for(:chrome)
  end
end


