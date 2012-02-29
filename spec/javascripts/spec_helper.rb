Flowerbox.configure do |c|
  c.test_with :jasmine
  c.run_with :node

  c.spec_patterns << "*_spec.*"
  c.spec_patterns << "**/*_spec.*"

  c.test_environment.reporters << "SimpleNodeReporter"
end

