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
    Flowerbox.contact("finish_test", spec.description, spec.results())
  reportRunnerResults: (runner) ->
    Flowerbox.contact("results", (new Date().getTime()) - @time)

