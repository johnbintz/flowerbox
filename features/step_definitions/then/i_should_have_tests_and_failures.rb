require 'json'

Then /^I should have (\d+) tests? and (\d+) failures?$/ do |tests, failures|
  results = JSON.parse(@output).last.last

  results['total'].should == tests.to_i
  results['failures'].should == failures.to_i
end

