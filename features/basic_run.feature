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
      class @Cat
        meow: -> "meow"
      """

  Scenario: Use the Node runner using Jasmine
    Given I have the file "spec/javascripts/spec_helper.rb" with the content:
      """
      Flowerbox.configure do |c|
        c.test_with :jasmine
        c.run_with :node

        c.spec_patterns << "**/*_spec.*"
        c.asset_paths << "lib"

        c.reporters << :json
      end
      """
    When I run Flowerbox with "spec/javascripts"
    Then I should have 1 test and 0 failures

  @wip
  Scenario: Use the Selenium runner using Jasmine
    Given I have the file "spec/javascripts/spec_helper.rb" with the content:
      """
      Flowerbox.configure do |c|
        c.test_with :jasmine
        c.run_with :chrome

        c.spec_patterns << "**/*_spec.*"
        c.asset_paths << "lib"

        c.reporters << :json
      end
      """
    When I run Flowerbox with "spec/javascripts"
    Then I should have 1 test and 0 failures

