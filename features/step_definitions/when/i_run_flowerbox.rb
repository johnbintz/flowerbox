When /^I run Flowerbox with "([^"]*)"$/ do |arguments|
  command = %{bundle exec bin/flowerbox test #{arguments} --pwd #{@root} 2>&1}
  puts command
  @output = %x{#{command}}

  puts @output

  raise StandardError.new("Flowerbox failed: #{@output}") if $?.exitstatus != 0
end

