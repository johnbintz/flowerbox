class jasmine.FlowerboxReporter
  buildResult: (spec, overrides = {}) ->
    data =
      status: Flowerbox.Result.SUCCESS
      source: 'jasmine'
      name: spec.getSpecSplitName()
      file: 'unknown:0'

    for key, value of overrides
      data[key] = value

    new Flowerbox.Result(data)

  reportRunnerStarting: (runner) ->
    @time = (new Date()).getTime()

    Flowerbox.contact("starting")

  reportSpecStarting: (spec) ->
    Flowerbox.contact("start_test", spec.getSpecSplitName().join(" "))

    if spec.description == 'encountered a declaration exception'
      Flowerbox.contact("finish_test", this.buildResult(spec, status: Flowerbox.Result.FAILURE))

  reportSpecWaiting: ->
    @paused = true
    Flowerbox.contact('pause_timer')

  reportSpecRunning: ->
    @paused = false
    Flowerbox.contact('unpause_timer')

  reportSpecResults: (spec) ->
    this.reportSpecRunning() if @paused

    result = this.buildResult(spec)

    for item in spec.results().items_
      if !item.passed_
        result.status = Flowerbox.Result.FAILURE

        stack = item.trace.stack || []
        if stack.constructor != Array
          stack = stack.split("\n")

        failure = { runner: Flowerbox.environment, message: item.message, stack: stack }

        result.failures.push(failure)

    Flowerbox.contact("finish_test", result)
  reportRunnerResults: (runner) ->
    Flowerbox.contact("results", (new Date().getTime()) - @time)

