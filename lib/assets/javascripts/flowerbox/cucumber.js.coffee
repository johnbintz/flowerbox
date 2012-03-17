#= require flowerbox/cucumber/reporter

Flowerbox.Cucumber ||= {}
Flowerbox.Cucumber.features = ->
  Flowerbox.Cucumber.Features ||= []
  Flowerbox.Cucumber.Features.join("\n")

Flowerbox.World = (code = null) ->
  if code
    Flowerbox.World.Code ||= []
    Flowerbox.World.Code.push(code)
  else
    ->
      for code in (Flowerbox.World.Code || [])
        code.apply(this)

Flowerbox.Matchers =
  toEqual: (expected) ->
    @message = "Expected #{@actual} #{@notMessage} equal #{expected}"
    result = null

    if @actual? && expected?
      switch (typeof @actual)
        when 'object'
          result = true
          for key, value of @actual
            result = false if expected[key] != value

          for key, value of expected
            result = false if @actual[key] != value

    if result == null
      result = (@actual == expected)

    result

Flowerbox.World ->
  @assert = (what, message = 'failed') ->
    throw new Error(message) if !what

  @expect = (what) -> new Flowerbox.Matcher(what)

  @addMatchers = (data) -> Flowerbox.Matcher.addMatchers(data)

  Flowerbox.Matcher.matchers = {}
  @addMatchers(Flowerbox.Matchers)

class Flowerbox.Matcher
  @addMatchers: (data) ->
    for method, code of data
      Flowerbox.Matcher.matchers[method] = code

  constructor: (@actual, @_negated = false) ->
    @not = this.negated() if !@_negated
    @notMessage = if @_negated then "to not" else "to"

    generateMethod = (method) ->
      (args...) -> @fail() if !@maybeNegate(Flowerbox.Matcher.matchers[method].apply(this, args))

    for method, code of Flowerbox.Matcher.matchers
      this[method] = generateMethod(method)

  negated: ->
    new Flowerbox.Matcher(@actual, true)

  fail: ->
    throw new Error(@message)

  maybeNegate: (result) ->
    result = !result if @_negated
    result

Flowerbox.Step = (type, match, code) ->
  Flowerbox.World.Code ||= []
  Flowerbox.World.Code.push (args..., callback) ->
    this[type] match, (args..., callback) =>
      _pending = false
      @pending = -> _pending = true

      result = code.apply(this, args)

      if result? and result.__prototype__ == Error
        callback.fail(result)
      else
        if _pending then callback.pending("pending") else callback()

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
      nextLine = false
      if stack = (new Error()).stack
        for line in stack.split('\n')
          if nextLine
            result = if line.match(/__F__/)
              line.replace(/^.*__F__\/([^:]+:\d+).*$/, '$1')
            else
              line.replace(/^.*(\(| )([^:]+:\d+).*$/, '$2')

            Flowerbox.Step.files[match.toString()] = [ match, result ]
            break

          if line.match(/(Given|When|Then)/)
            nextLine = true

    Flowerbox.Step(type, match, code)

stepGenerator(type) for type in [ 'Given', 'When', 'Then' ]

