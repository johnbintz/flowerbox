Given /^I have the file "([^"]*)" with the content:$/ do |file, string|
  target = File.join(@root, file)

  FileUtils.mkdir_p File.dirname(target)
  File.open(target, 'wb') { |fh| fh.print string }
end

