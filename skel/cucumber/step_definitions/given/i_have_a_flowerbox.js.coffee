Flowerbox.Given /^I have a flowerbox$/, ->
  @flowerbox = 
    plantSeed: (type) ->
      @types ||= []
      @types.push(type)
    pick: ->
      @types

