class jasmine.FlowerboxReporter
  reportRunnerStarting: (runner) ->
    @time = (new Date()).getTime()

    Flowerbox.contact("starting")
  reportSpecStarting: (spec) ->
    Flowerbox.contact("start_test", spec.description)

    if spec.description == 'encountered a declaration exception'
      Flowerbox.contact("finish_test", spec.description, { trace: { stack: [ spec.description ] } })
      Flowerbox.contact("results", 0)
      Flowerbox.fail() if Flowerbox.fail?

  reportSpecResults: (spec) ->
    failures = []

    for result in spec.results().getItems()
      if result.type == 'expect' && !result.passed_
        failures.push(result)

    Flowerbox.contact("finish_test", spec.description, failures)
  reportRunnerResults: (runner) ->
    Flowerbox.contact("results", (new Date().getTime()) - @time)

