Flowerbox.configure do |f|
  f.test_with :cucumber
  f.run_with :firefox

  f.additional_files << "support/env.js.coffee"
  f.spec_patterns << "features/**/*.feature"

  f.test_environment.prefer_step_language :coffeescript
end

