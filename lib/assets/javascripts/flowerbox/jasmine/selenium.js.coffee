class jasmine.SimpleSeleniumReporter
  reportRunnerResults: (runner) ->
    xhr = new XMLHttpRequest()
    xhr.open("POST", "/results")
    xhr.send(runner.results().totalCount + '/' + runner.results().failedCount)

