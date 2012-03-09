Flowerbox =
  baseUrl: '/'
  contact: (url, data...) ->
    xhr = new XMLHttpRequest()
    xhr.open("POST", Flowerbox.baseUrl + url, false)
    xhr.setRequestHeader("Accept", "application/json")
    xhr.send(JSON.stringify(data))
  fail: ->
