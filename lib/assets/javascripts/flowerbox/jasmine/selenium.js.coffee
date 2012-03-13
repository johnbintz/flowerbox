jasmine.Spec.beforeAddMatcherResult().push ->
  if !@passed_
    @trace = { stack: [] }
    try
      lol.wut
    catch e
      if e.stack
        file = switch Flowerbox.environment
          when 'firefox'
            e.stack.split("\n")[3]
          when 'chrome'
            e.stack.split("\n")[4]

        @trace = { stack: [ file ] }

