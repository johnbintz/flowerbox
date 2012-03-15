#= require_self
#= require flowerbox/result
#= require flowerbox/exception
#
Flowerbox =
  baseUrl: '/'
  debug: false
  ping: ->
    Flowerbox.contact('ping')
  working: false

  contact: (url, data...) ->
    if !Flowerbox.debug
      Flowerbox.contactQueue ||= []

      Flowerbox.contactQueue.push([url, data])
      Flowerbox.workOffQueue()

  workOffQueue: ->
    if !Flowerbox.working
      Flowerbox.working = true
      Flowerbox.doWorkOffQueue()

  doWorkOffQueue: ->
    if Flowerbox.contactQueue.length > 0
      [ url, data ] = Flowerbox.contactQueue.shift()

      xhr = new XMLHttpRequest()
      xhr.open("POST", Flowerbox.baseUrl + url, true)
      xhr.setRequestHeader("Accept", "application/json")
      xhr.onreadystatechange = ->
        if @readyState == @DONE
          Flowerbox.doWorkOffQueue()
      xhr.send(JSON.stringify(data))
    else
      Flowerbox.working = false

  fail: ->

