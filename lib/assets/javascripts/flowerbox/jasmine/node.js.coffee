jasmine.Spec.beforeAddMatcherResult().push ->
  if !@passed_
    Error.prepareStackTrace_ = Error.prepareStackTrace
    Error.prepareStackTrace = (err, stack) -> stack

    errorInfo = new Error().stack[3]

    @trace = { stack: [ "#{errorInfo.getFileName()}:#{errorInfo.getLineNumber()}" ] }

    Error.prepareStackTrace = Error.prepareStackTrace_

