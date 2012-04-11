Flowerbox = Flowerbox || {}
Flowerbox.Cucumber = Flowerbox.Cucumber || {}

class Flowerbox.Cucumber.Reporter
  nameParts: ->
    [ @feature.getName(), @scenario.getName(), "#{this.type()} #{@step.getName()}" ]

  type: ->
    type = "Given"

    if @step.isOutcomeStep()
      type = "Then"
    else if @step.isEventStep()
      type = "When"

    type

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

        file = Flowerbox.Step.matchFile(@step.getName()) || "#{Flowerbox.UNKNOWN}:0"

        result = new Flowerbox.Result(step_type: this.type(), source: 'cucumber', original_name: @step.getName(), name: this.nameParts(), file: file)

        if stepResult.isSuccessful()
          result.status = Flowerbox.Result.SUCCESS
        else if stepResult.isPending()
          result.status = Flowerbox.Result.PENDING
        else if stepResult.isUndefined()
          result.status = Flowerbox.Result.UNDEFINED
          result.hasDataTable = @step.hasDataTable()
          result.hasDocString = @step.hasDocString()
        else if stepResult.isFailed()
          result.status = Flowerbox.Result.FAILURE

          error = stepResult.getFailureException()
          stack = (error.stack || "message\n#{file}:0").split("\n")

          failure = { runner: Flowerbox.environment, message: error.message, stack: stack }

          result.failures.push(failure)

        Flowerbox.contact("finish_test", result.toJSON())

    callback()

