jasmine.Spec.beforeAddMatcherResult().push ->
  if !@passed_
    @trace = { stack: new Error().stack }

Flowerbox.fail = -> process.exit(1)
