class Flowerbox::Runner::Firefox < Flowerbox::Runner::Selenium
  def name
    "Firefox"
  end

  def browser
    :firefox
  end
end

