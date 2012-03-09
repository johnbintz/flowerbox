Flowerbox ||= {}
Flowerbox.Cucumber ||= {}

class Flowerbox.Cucumber.Reporter
  hear: (event, callback) ->
    switch event.getName()
      when 'BeforeFeatures'
        @time = (new Date()).getTime()

        Flowerbox.contact("starting")

      when 'AfterFeatures'
        Flowerbox.contact("results", (new Date()).getTime() - @time)

      when 'BeforeFeature'
        @feature = event.getPayloadItem('feature')

      when 'BeforeScenario'
        @scenario = event.getPayloadItem('scenario')

      when 'BeforeStep'
        @step = event.getPayloadItem('step')

        Flowerbox.contact("start_test", @step.getName())

      when 'StepResult'
        stepResult = event.getPayloadItem('stepResult')

        type = "Given"

        if @step.isOutcomeStep()
          type = "Then"
        else if @step.isEventStep()
          type = "When"

        file = Flowerbox.Step.matchFile(@step.getName()) || "unknown:0"

        test = { passed_: false, message: 'skipped', splitName: [ @feature.getName(), @scenario.getName(), "#{type} #{@step.getName()}" ], trace: { stack: [ file ] } }

        if stepResult.isSuccessful()
          test.passed_ = true
        else if stepResult.isPending()
          test.message = "pending"
        else if stepResult.isUndefined()
          regexp = @step.getName()
          regexp = regexp.replace(/"[^"]+"/g, '"([^"]+)"')

          test.message = """
                         Step not defined. Define it with the following:

                         Flowerbox.#{type} /^#{regexp}$/, ->
                           @pending()


                         """
        else if stepResult.isFailed()
          error = stepResult.getFailureException()

          test.message = error.message
          test.trace.stack = [ 'file:1' ]

        Flowerbox.contact("finish_test", @step.getName(), [ { items_: [ test ] } ])

    callback()

