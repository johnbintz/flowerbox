class jasmine.FlowerboxReporter
  reportRunnerStarting: (runner) ->
    @time = (new Date()).getTime()

    Flowerbox.contact("starting")
  reportSpecStarting: (spec) ->
    Flowerbox.contact("start_test", spec.description)
  reportSpecResults: (spec) ->
    failures = []

    for result in spec.results().getItems()
      if result.type == 'expect' && !result.passed_
        failures.push(result)

    Flowerbox.contact("finish_test", spec.description, failures)
  reportRunnerResults: (runner) ->
    Flowerbox.contact("results", (new Date().getTime()) - @time)

