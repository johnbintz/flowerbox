class Flowerbox.Exception
  constructor: (@source, @name, @stack) ->

  toJSON: ->
    { status: Flowerbox.Result.FAILURE, source: @source, name: @name, trace: { stack: @stack } }
