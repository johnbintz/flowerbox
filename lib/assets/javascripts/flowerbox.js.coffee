#= require_self
#= require flowerbox/result
#= require flowerbox/exception
#
Flowerbox =
  baseUrl: '/'
  debug: false
  ping: ->
    Flowerbox.contact('ping')

  contactQueue: []

  contact: (url, data...) ->
    if !Flowerbox.debug
      Flowerbox.contactQueue.push([url, data])

  queueIndex: 0
  delay: 40
  started: false
  done: false

  onQueueStateChange: ->

  queueRunner: ->
    Flowerbox.onQueueStateChange("checking queue")
    if Flowerbox.contactQueue.length > 0
      Flowerbox.started = true

      info = Flowerbox.contactQueue.shift()

      [ url, data ] = info

      xhr = new XMLHttpRequest()
      xhr.open("POST", Flowerbox.baseUrl + url, true)
      xhr.setRequestHeader("Accept", "application/json")
      done = false
      xhr.onreadystatechange = ->
        if xhr.readyState == 4
          done = true
          Flowerbox.onQueueStateChange("done #{url}")
          if url == "results"
            Flowerbox.onQueueStateChange("finsihed all tests")
            Flowerbox.done = true
          else
            setTimeout(
              ->
                Flowerbox.queueRunner()
              , 1
            )
      Flowerbox.onQueueStateChange("running #{url}")

      setTimeout(
        ->
          if xhr.readyState != 4
            xhr.abort()
            Flowerbox.onQueueStateChange("aborted #{url}, rerunning")
            Flowerbox.contactQueue.unshift(info)
            Flowerbox.queueRunner()
        , Flowerbox.delay * 5
      )

      xhr.send(JSON.stringify(data))
    else
      Flowerbox.startQueueRunner()

  startQueueRunner: ->
    setTimeout(
      -> 
        Flowerbox.queueRunner()
      , Flowerbox.delay
    )

  fail: ->

