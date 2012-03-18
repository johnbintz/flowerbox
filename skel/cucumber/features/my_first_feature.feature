Feature: My First Feature
  Scenario: Do Something
    Given I have a flowerbox
    When I plant a "cucumber" seed
    Then I should get the following when I pick:
      | cucumber |

