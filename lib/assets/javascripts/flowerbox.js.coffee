#= require_self
#= require flowerbox/result
#= require flowerbox/exception
#
Flowerbox =
  baseUrl: '/'
  ping: ->
    Flowerbox.contact('ping')

  pause: (time) ->
    t = (new Date()).getTime()

    while (t + time) > (new Date().getTime())
      Flowerbox.ping()

  contact: (url, data...) ->
    attempts = 3

    doContact = ->
      attempts -= 1

      try
        xhr = new XMLHttpRequest()
        xhr.open("POST", Flowerbox.baseUrl + url, false)
        xhr.setRequestHeader("Accept", "application/json")
        xhr.send(JSON.stringify(data))
      catch e
        if attempts == 0
          throw e
        else
          doContact()

    doContact()
  fail: ->

