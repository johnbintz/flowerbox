#= require flowerbox/jasmine/reporter

# because why not?
@context = @describe

getSplitName = (parts) ->
  parts.push(String(@description).replace(/[\n\r]/g, ' '))
  parts

jasmine.Suite.prototype.getSuiteSplitName = ->
  this.getSplitName(if @parentSuite then @parentSuite.getSuiteSplitName() else [])

jasmine.Spec.prototype.getSpecSplitName = ->
  this.getSplitName(@suite.getSuiteSplitName())

jasmine.Suite.prototype.getSplitName = getSplitName
jasmine.Spec.prototype.getSplitName = getSplitName

jasmine.Spec.prototype.addMatcherResult = (result) ->
  for method in jasmine.Spec.beforeAddMatcherResult()
    method.apply(result, [ this ])

  @results_.addResult(result)

jasmine.Spec.beforeAddMatcherResult = ->
  @_beforeAddMatcherResult ||= []

jasmine.Spec.beforeAddMatcherResult().push (spec) ->
  @splitName = spec.getSpecSplitName()

Flowerbox.only = (envs..., code) ->
  for env in envs
    if Flowerbox.environment == env
      describe("only in #{envs.join(', ')}", code)

jasmine.WaitsBlock.prototype._execute = jasmine.WaitsBlock.prototype.execute
jasmine.WaitsForBlock.prototype._execute = jasmine.WaitsForBlock.prototype.execute

pauseAndRun = (onComplete) ->
  jasmine.getEnv().reporter.reportSpecWaiting()

  this._execute ->
    jasmine.getEnv().reporter.reportSpecRunning()
    onComplete()

jasmine.WaitsBlock.prototype.execute = pauseAndRun
jasmine.WaitsForBlock.prototype.execute = pauseAndRun

for method in [ "reportSpecWaiting", "reportSpecRunning" ]
  generator = (method) ->
    (args...) ->
      for reporter in @subReporters_
        if reporter[method]?
          reporter[method](args...)

  jasmine.MultiReporter.prototype[method] = generator(method)

