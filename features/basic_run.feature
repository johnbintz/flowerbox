Feature: Basic Run
  Background:
    Given I have the file "spec/javascripts/cat_spec.js.coffee" with the content:
      """
      #= require cat

      describe 'Cat', ->
        describe '#meow', ->
          it 'should meow', ->
            cat = new Cat()

            expect(cat.meow()).toEqual('meow')
      """
    Given I have the file "lib/cat.js.coffee" with the content:
      """
      class Cat
        meow: -> "meow"

      console.log("made it")
      """

  Scenario: Use the Node runner using Jasmine
    Given I have the file "spec/javascripts/spec_helper.rb" with the content:
      """
      Flowerbox.configure do |c|
        c.test_with :jasmine
        c.run_with :node

        c.spec_patterns << "**/*_spec.*"
        c.asset_paths << "lib"
        c.bare_coffeescript = true

        c.test_environment.reporters << "SimpleNodeReporter"
      end
      """
    When I run Flowerbox with "spec/javascripts"
    Then I should have 1 test and 0 failures

  Scenario: Use the Selenium runner using Jasmine
    Given I have the file "spec/javascripts/spec_helper.rb" with the content:
      """
      Flowerbox.configure do |c|
        c.test_with :jasmine
        c.run_with :selenium
        c.runner_environment.browser = :firefox

        c.spec_patterns << "**/*_spec.*"
        c.asset_paths << "lib"
        c.bare_coffeescript = true

        c.test_environment.reporters << "SimpleSeleniumReporter"
      end
      """
    When I run Flowerbox with "spec/javascripts"
    Then I should have 1 test and 0 failures

