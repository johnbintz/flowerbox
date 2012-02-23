class jasmine.SimpleNodeReporter
  reportRunnerResults: (runner) ->
    console.log(runner.results().totalCount + '/' + runner.results().failedCount)

    if runner.results().failedCount == 0
      process.exit(0)
    else
      process.exit(1)

