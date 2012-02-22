Then /^I should have (\d+) tests? and (\d+) failures?$/ do |tests, failures|
  parts = @output.lines.to_a.last.strip.split('/')

  parts[0].should == tests
  parts[1].should == failures
end

