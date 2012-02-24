class jasmine.SimpleSeleniumReporter
  reportRunnerResults: (runner) ->
    Flowerbox.contact("results", runner.results().totalCount + '/' + runner.results().failedCount)
