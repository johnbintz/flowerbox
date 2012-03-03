Flowerbox =
  baseUrl: '/'
  contact: (url, data...) ->
    xhr = new XMLHttpRequest()
    xhr.open("POST", Flowerbox.baseUrl + url, false)
    xhr.send(JSON.stringify(data))
  fail: ->
