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

