class jasmine.FlowerboxReporter
  reportRunnerStarting: (runner) ->
    @time = (new Date()).getTime()

    Flowerbox.contact("starting")
  reportSpecStarting: (spec) ->
    Flowerbox.contact("start_test", spec.description)

    if spec.description == 'encountered a declaration exception'
      Flowerbox.contact("finish_test", new Flowerbox.Exception([ spec.description ]))
      Flowerbox.contact("results", 0)
      Flowerbox.fail() if Flowerbox.fail?

  reportSpecResults: (spec) ->
    result = new Flowerbox.Result(status: Flowerbox.Result.SUCCESS, source: 'jasmine', name: spec.getSpecSplitName(), file: 'unknown:0')

    for item in spec.results().items_
      if !item.passed_
        result.status = Flowerbox.Result.FAILURE
        failure = { runner: Flowerbox.environment, message: item.message, stack: item.trace.stack }

        result.failures.push(failure)

    Flowerbox.contact("finish_test", result)
  reportRunnerResults: (runner) ->
    Flowerbox.contact("results", (new Date().getTime()) - @time)

