#= require_self
#= require flowerbox/result
#= require flowerbox/exception
#
Flowerbox =
  baseUrl: '/'
  debug: false
  ping: ->
    Flowerbox.contact('ping')

  contact: (url, data...) ->
    if !Flowerbox.debug
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

