# Description:
#   Info about all the nerd beers chapters
#
# Dependencies:
#   "moment": "^2.6.0"
#
# Commands:
#   hubot nerdbeers - get the current OKC NerdBeers agenda
#   hubot okc nerdbeers - get the current OKC NerdBeers agenda
#   hubot okcnerdbeers - get the current OKC NerdBeers agenda
#   hubot nerdbeers humans - get the NerdBeers humans.txt
#   hubot nerdbeers suggestions - get the recent NerdBeers suggestions
#   hubot nerdbeers help - list the hubot nerdbeers commands
#
# Notes:
#   Have fun with it.
#
# Author:
#   ryoe
moment = require 'moment'

baseUrl = 'http://www.nerdbeers.com/'
apiUrl  = 'http://www.nerdbeers.com/api'
help = [
  'hubot nerdbeers - get the current OKC NerdBeers agenda'
  'hubot okc nerdbeers - get the current OKC NerdBeers agenda'
  'hubot okcnerdbeers - get the current OKC NerdBeers agenda'
  'hubot nerdbeers humans - get the NerdBeers humans.txt'
  'hubot nerdbeers suggestions - get the recent NerdBeers suggestions'
  'hubot nerdbeers help - list the hubot nerdbeers commands'
]
topicEmoji = '' #no good HipChat emoji for this...
beerEmoji  = ' (beer) '

showSuggestions = (msg) ->
  cmd = adapterFormat "hubot nerdbeers suggestions"
  msg.send "#{cmd} is coming soon!\nUntil then, visit #{baseUrl}suggestions"

adapterFormat = (text) ->
  if process.env.HUBOT_SLACK_TOKEN
    "*#{text}*"
  else
    text

showHumans = (msg) ->
  msg.http("#{baseUrl}humans.txt")
    .get() (err, res, body) ->
      if err
        msg.send "#{err}"
        return

      if res.statusCode == 200
        msg.send body
      else
        msg.send "statusCode: #{err}\n#{body}"

chapterAgenda = (msg, chapterId) ->
  url = apiUrl + '/agenda'

  apiCall msg, url, (err, body) ->
    #console.log msg
    if err
      msg.send body
      return

    data = JSON.parse(body)

    if data?
      date = moment.utc data.meeting_date 
      if process.env.HUBOT_SLACK_TOKEN
        agenda = formatSlack data, date
        msg.message_format = 'html'
        msg.send agenda.join '\n'
      else
        agenda = formatHipChat data, date
        msg.send agenda.join '\n'
    else
      msg.send body

formatSlack = (data, date) ->
  agenda = ["*NerdBeers Agenda*"]
  agenda.push "#{topicEmoji}#{d.topic} - #{beerEmoji} #{d.beer}" for d in data.pairings
  agenda.push "*When:* " + date.format 'MMM DD, YYYY hh:mma'
  agenda.push "*Where:* #{data.venue_name} ( #{data.map_link}|Map )" if data.venue_name
  agenda

formatHipChat = (data, date) ->
  agenda = ["NerdBeers Agenda"]
  agenda.push "#{topicEmoji}#{d.topic} - #{beerEmoji} #{d.beer}" for d in data.pairings
  agenda.push "When: " + date.format 'MMM DD, YYYY hh:mma'
  agenda.push "Where: #{data.venue_name}" if data.venue_name
  agenda.push "More Info: #{baseUrl}" if data.venue_name
  agenda

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
  if process.env.HUBOT_SLACK_TOKEN
    topicEmoji = ':wrench: '
    beerEmoji  = ' :beer: '
  robot.respond /(nerdbeers|okcnerdbeers|okc nerdbeers){1}( help)?( humans)?( suggestion)?/i, (msg) ->
    cmdHelp = msg.match[2] or null
    cmdHumans = msg.match[3] or null
    cmdSuggestions = msg.match[4] or null
    if cmdHelp
      msg.send help.join '\n'
    else if cmdHumans
      showHumans msg
    else if cmdSuggestions
      showSuggestions msg
    else
      chapterAgenda msg, 'okc'
