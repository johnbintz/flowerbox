When /^I run Flowerbox with "([^"]*)"$/ do |arguments|
  command = %{bundle exec bin/flowerbox test #{arguments} -q --pwd #{@root} 2>&1}

  @output = %x{#{command}}

  raise StandardError.new("Flowerbox failed: #{@output}") if $?.exitstatus != 0
end

