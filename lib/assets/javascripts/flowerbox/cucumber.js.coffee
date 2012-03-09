#= require flowerbox/cucumber/reporter

Flowerbox.Cucumber ||= {}
Flowerbox.Cucumber.features = ->
  Flowerbox.Cucumber.Features ||= []
  Flowerbox.Cucumber.Features.join("\n")

Flowerbox.World = (code = null) ->
  ->
    for code in (Flowerbox.World.Code || [])
      code.apply(this)

Flowerbox.Step = (type, match, code) ->
  Flowerbox.World.Code ||= []
  Flowerbox.World.Code.push (args..., callback) ->
    this[type] match, (args..., callback) ->

      pending = false

      this.pending = -> pending = true

      result = code.apply(this)

      if result? and result.__prototype__ == Error
        callback.fail(result)
      else
        if pending then callback.pending("pending") else callback()

      null

Flowerbox.Step.files ||= {}
Flowerbox.Step.matchFile = (name) ->
  for key, data of Flowerbox.Step.files
    [ regexp, filename ] = data
    if name.match(regexp)
      return filename

  null

stepGenerator = (type) ->
  Flowerbox[type] = (match, code) ->
    if !Flowerbox.Step.files[match.toString()]
      count = 2
      for line in (new Error()).stack.split('\n')
        if line.match(/__F__/)
          count -= 1

          if count == 0
            Flowerbox.Step.files[match.toString()] = [ match, line.replace(/^.*__F__/, '') ]
            break

    Flowerbox.Step(type, match, code)

stepGenerator(type) for type in [ 'Given', 'When', 'Then' ]

