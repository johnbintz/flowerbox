class Flowerbox::Runner::Chrome < Flowerbox::Runner::Selenium
  def name
    "Chrome"
  end

  def browser
    :chrome
  end
end


