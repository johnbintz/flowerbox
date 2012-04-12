Flowerbox =
  debug: false
  ping: ->
    Flowerbox.contact('ping')

  messageQueue: []
  pulling: false

  contact: (url, data...) ->
    Flowerbox.started = true

    if !Flowerbox.debug
      message = [ url, data ]
      Flowerbox.messageQueue.push(message)

      if Flowerbox.socket && !Flowerbox.pulling
        Flowerbox.queuePuller()

  started: false
  done: false

  queuePuller: ->
    Flowerbox.pulling = true

    if Flowerbox.messageQueue.length > 0
      message = Flowerbox.messageQueue.shift()

      Flowerbox.socket.onmessage = (data) ->
        if message[0] == 'results'
          if __$instrument?
            Flowerbox.socket.send JSON.stringify(['instrument', __$instrument]) {}, ->
              Flowerbox.done = true
          else
            Flowerbox.done = true

        Flowerbox.queuePuller()

      Flowerbox.socket.send JSON.stringify(message)
    else
      setTimeout(Flowerbox.queuePuller, 10) if !Flowerbox.done

  fail: ->

class Flowerbox.Exception
  constructor: (@source, @name, @stack) ->

  toJSON: ->
    { status: Flowerbox.Result.FAILURE, source: @source, name: @name, trace: { stack: @stack } }

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

