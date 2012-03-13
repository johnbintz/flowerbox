class Flowerbox.Exception
  constructor: (@stack) ->

  toJSON: ->
    { trace: { stack: @stack } }
