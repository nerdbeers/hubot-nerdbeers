# Description:
#   Info about all the nerd beers chapters
#
# Dependencies:
#   none
#
# Commands:
#   hubot nerdbeers - get the current OKC NerdBeers agenda
#   hubot okc nerdbeers - get the current OKC NerdBeers agenda
#   hubot okcnerdbeers - get the current OKC NerdBeers agenda
#   hubot nerdbeers help - list the hubot nerdbeers commands
#
# Notes:
#   Have fun with it.
#
# Author:
#   ryoe

apiUrl = 'http://www.nerdbeers.com/api'
help = [
  'hubot nerdbeers - get the current OKC NerdBeers agenda'
  'hubot okc nerdbeers - get the current OKC NerdBeers agenda'
  'hubot okcnerdbeers - get the current OKC NerdBeers agenda'
  'hubot nerdbeers help - list the hubot nerdbeers commands'
]

chapterAgenda = (msg, chapterId) ->
  url = apiUrl + '/agenda'

  apiCall msg, url, (err, body) ->
    if err
      msg.send body
      return

    data = JSON.parse(body)

    if data?
      agenda = ['NerdBeers Agenda']
      agenda.push 'Topic ' + d.id.toString() + ': ' + d.topic + ' - ' + '(beer) ' + d.beer for d in data.pairings
      agenda.push 'When: ' + data.meeting_date
      agenda.push 'Where: ' + data.venue_name if data.venue_name
      agenda.push 'Map: ' + data.map_link if data.map_link
      msg.send agenda.join '\n'
    else
      msg.send body

apiCall = (msg, url, cb) ->
  msg.http(url)
    .headers(Accept: 'application/json')
    .get() (err, res, body) ->
      if err
        cb err, ['error']
        return

      if res.statusCode == 200
        cb null, body
      else
        cb res.statusCode, body

module.exports = (robot) ->
  robot.respond /(nerdbeers|okcnerdbeers|okc nerdbeers){1}( help)?/i, (msg) ->
    showHelp = msg.match[2] or null
    if showHelp
      msg.send help.join '\n'
    else
      chapterAgenda msg, 'okc'
