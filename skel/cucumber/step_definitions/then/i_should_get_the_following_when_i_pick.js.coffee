Flowerbox.Then /^I should get the following when I pick:$/, (table) ->
  # table is a Cucumber AST data table
  data = (row[0] for row in table.raw())
  @expect(@flowerbox.pick()).toEqual(data)
 
