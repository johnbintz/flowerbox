Flowerbox ||= {}

class Flowerbox.Result
  @SUCCESS = 'success'
  @PENDING = 'pending'
  @UNDEFINED = 'undefined'
  @FAILURE = 'failure'
  @SKIPPED = 'skipped'

  constructor: (data) ->
    for key, value of data
      this[key] = value

    this.status ||= Flowerbox.Result.SKIPPED
    this.failures ||= []

  toJSON: => this
