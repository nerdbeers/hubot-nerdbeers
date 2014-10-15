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
#   hubot nerdbeers cowsay - get the current OKC NerdBeers agenda cowsay-style
#   hubot nerdbeers humans - get the NerdBeers humans.txt
#   hubot nerdbeers suggestions - get the recent NerdBeers suggestions
#   hubot nerdbeers suggest beer <beer> - add a beer to the NerdBeers suggestions
#   hubot nerdbeers suggest topic <topic> - add a topic to the NerdBeers suggestions
#   hubot nerdbeers help - list the hubot nerdbeers commands
#   Agenda has been updated - respond with most recent agenda
# Notes:
#   Have fun with it.
#
# Author:
#   ryoe
moment = require 'moment'
qs = require 'querystring'

baseUrl = 'http://www.nerdbeers.com/'
apiUrl  = 'http://www.nerdbeers.com/api'
help = [
  'hubot nerdbeers - get the current OKC NerdBeers agenda'
  'hubot okc nerdbeers - get the current OKC NerdBeers agenda'
  'hubot okcnerdbeers - get the current OKC NerdBeers agenda'
  'hubot nerdbeers cowsay - get the current OKC NerdBeers agenda cowsay-style'
  'hubot nerdbeers humans - get the NerdBeers humans.txt'
  'hubot nerdbeers suggestions - get the recent NerdBeers suggestions'
  'hubot nerdbeers suggest beer <beer> - add a beer to the NerdBeers suggestions'
  'hubot nerdbeers suggest topic <topic> - add a topic to the NerdBeers suggestions'
  'hubot nerdbeers help - list the hubot nerdbeers commands'
]
f5_suggestions = [
  'Have you considered Coop F5?'
  'May I suggest Coop F5?'
  'Many nerds like a tasty IPA like COOP F5.'
]
reF5 = new RegExp('F5','i')
topicEmoji = '' #no good HipChat emoji for this...
beerEmoji  = ' (beer) '
moreSuggestions = "\nFor more suggestions, visit #{baseUrl}suggestions"

postSuggestion = (msg, beer, topic, cb) ->
  #apiUrl = 'http://localhost:3000/api'
  url = "#{apiUrl}/suggestions/new"
  beerParam = if beer then encodeURIComponent(beer) else ''
  topicParam = if topic then encodeURIComponent(topic) else ''
  params = "suggestion%5Btopic%5D=#{topicParam}&suggestion%5Bbeer%5D=#{beerParam}"

  msg.http("#{url}?#{params}")
    .post() (err, res, body) ->
      if err
        msg.send "#{err}"
        return

      if res.statusCode == 201
        cb()
      else
        msg.send "statusCode: #{res.statusCode}\n#{body}"

showSuggestions = (msg) ->
  url = apiUrl + '/suggestions'

  apiCall msg, url, (err, body) ->
    if err
      msg.send body
      return

    suggestions = JSON.parse(body)

    if suggestions?
      data = {}
      data.pairings = suggestions
      date = null
      if process.env.HUBOT_SLACK_TOKEN
        agenda = formatSlack data, date, 'NerdBeers Recent Suggestions'
        agenda.push moreSuggestions
        msg.message_format = 'html'
        msg.send agenda.join '\n'
      else
        agenda = formatHipChat data, date, 'NerdBeers Recent Suggestions'
        agenda.push moreSuggestions
        msg.send agenda.join '\n'
    else
      msg.send body

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
    if err
      msg.send body
      return

    data = JSON.parse(body)

    if data?
      date = moment.utc data.meeting_date 
      if process.env.HUBOT_SLACK_TOKEN
        agenda = formatSlack data, date, "NerdBeers Agenda"
        msg.message_format = 'html'
        msg.send agenda.join '\n'
      else
        agenda = formatHipChat data, date, "NerdBeers Agenda"
        msg.send agenda.join '\n'
    else
      msg.send body

cowsayAgenda = (msg, chapterId) ->
  url = apiUrl + '/agenda'

  apiCall msg, url, (err, body) ->
    if err
      msg.send body
      return

    data = JSON.parse(body)

    if data?
      date = moment.utc data.meeting_date 
      agenda = formatHipChat data, date, "NerdBeers Agenda"
      message = encodeURIComponent agenda.join '\r\n' 
      format = 'text'
      url = "http://cowsay.morecode.org/say?message=#{message}&format=#{format}"

      apiCall msg, url, (err, textBody) ->
        if err
          msg.send textBody
          return
        msg.send textBody
    else
      msg.send body

formatSlack = (data, date, title) ->
  agenda = ["*#{title}*"]
  agenda.push "#{topicEmoji}#{d.topic} - #{beerEmoji} #{d.beer}" for d in data.pairings
  agenda.push "*When:* " + date.format 'MMM DD, YYYY hh:mma' if date
  agenda.push "*Where:* #{data.venue_name} ( #{data.map_link}|Map )" if data.venue_name
  agenda

formatHipChat = (data, date, title) ->
  agenda = ["#{title}"]
  agenda.push "#{topicEmoji}#{d.topic} - #{beerEmoji} #{d.beer}" for d in data.pairings
  agenda.push "When: " + date.format 'MMM DD, YYYY hh:mma' if date
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

apiPostCall = (msg, url, postBody, cb) ->
  console.log postBody
  postData = JSON.stringify(postBody)
  console.log postData
  msg.http(url)
    .headers(Accept: 'application/json')
    .header('Content-Type','application/json')
    .post(postData) (err, res, body) ->
      if err
        console.log 'error'
        console.log err
        cb err, res.statusCode, ['error']
        return
      
      cb null, res.statusCode, body

module.exports = (robot) ->
  if process.env.HUBOT_SLACK_TOKEN
    topicEmoji = ':wrench: '
    beerEmoji  = ' :beer: '
  robot.hear /Agenda has been updated/i, (msg) ->
    chapterAgenda msg, 'okc'

  robot.respond /(nerdbeers|okcnerdbeers|okc nerdbeers){1}( help)?( humans)?( agenda cowsay)?( cowsay)?( suggest|suggestion)?( beer)?( topic)?( .*)?/i, (msg) ->
    cmdHelp = msg.match[2] or null
    cmdHumans = msg.match[3] or null
    cmdCowsay = msg.match[4] or msg.match[5] or null
    cmdSuggestions = msg.match[6] or null
    cmdBeer = msg.match[7] or null
    cmdTopic = msg.match[8] or null
    suggestion = msg.match[9] or null
    console.log msg.match
    if cmdHelp
      msg.send help.join '\n'
    else if cmdHumans
      showHumans msg
    else if cmdSuggestions and cmdBeer
      msg.reply "Please try again and include a beer!" if not suggestion
      msg.emote msg.random f5_suggestions if not suggestion

      if suggestion
        postSuggestion msg, suggestion, null, () ->
          msg.reply "Thanks for your beer suggestion#{suggestion}!" if suggestion
          msg.emote msg.random f5_suggestions if suggestion and not reF5.test(suggestion)

    else if cmdSuggestions and cmdTopic
      msg.reply "Please try again and include a topic!" if not suggestion

      if suggestion
        postSuggestion msg, null, suggestion, () ->
          msg.reply "Thanks for suggesting topic#{suggestion}!" if suggestion

    else if cmdSuggestions
      showSuggestions msg
    else if cmdCowsay
      cowsayAgenda msg
    else
      chapterAgenda msg, 'okc'

  robot.router.get '/hubot/agendaupdate', (req, res) ->
    defaultRoom = 'general'
    q    = qs.parse req._parsedUrl.query
    room = q.room or process.env.HUBOT_NERDBEERS_NOTIFY_ROOM or defaultRoom or null
    roomWarn = if (process.env.HUBOT_NERDBEERS_NOTIFY_ROOM || null)? then '' else '\n* HUBOT_NERDBEERS_NOTIFY_ROOM environment variable not set'

    res.end "GET agendaupdate:* room: #{room}#{roomWarn}"

    url = apiUrl + '/agenda'
    robot.http(url)
      .headers(Accept: 'application/json')
      .get() (err, res, body) ->
        if err
          cb err, ['error']
          return

        if res.statusCode == 200
          data = JSON.parse(body)

          if data?
            date = moment.utc data.meeting_date 
            if process.env.HUBOT_SLACK_TOKEN
              agenda = formatSlack data, date, "NerdBeers Agenda"
              dataMsg = ":boom:\n*Agenda has been updated!*\n\n"
              dataMsg += agenda.join '\n'
            else
              agenda = formatHipChat data, date, "NerdBeers Agenda"
              dataMsg = agenda.join '\n'
          else
            dataMsg = body
        else
          dataMsg = "#{res.statusCode}\n#{body}"

        #send the message for all to see!
        #console.log dataMsg
        robot.messageRoom "##{room}", "#{dataMsg}"

  robot.router.get '/hubot/suggestionsupdate', (req, res) ->
    defaultRoom = 'general'
    q    = qs.parse req._parsedUrl.query
    room = q.room or process.env.HUBOT_NERDBEERS_NOTIFY_ROOM or defaultRoom or null
    roomWarn = if (process.env.HUBOT_NERDBEERS_NOTIFY_ROOM || null)? then '' else '\n* HUBOT_NERDBEERS_NOTIFY_ROOM environment variable not set'

    res.end "GET suggestionsupdate:* room: #{room}#{roomWarn}"

    url = apiUrl + '/suggestions'
    robot.http(url)
      .headers(Accept: 'application/json')
      .get() (err, res, body) ->
        if err
          cb err, ['error']
          return

        if res.statusCode == 200
          suggestions = JSON.parse(body)

          if suggestions?
            data = {}
            data.pairings = suggestions
            date = null
            if process.env.HUBOT_SLACK_TOKEN
              agenda = formatSlack data, date, 'NerdBeers Recent Suggestions'
              agenda.push moreSuggestions
              dataMsg = ":boom:\n*Suggestions have been updated!*\n\n"
              dataMsg += agenda.join '\n'
            else
              agenda = formatHipChat data, date, 'NerdBeers Recent Suggestions'
              agenda.push moreSuggestions
              dataMsg = agenda.join '\n'
          else
            dataMsg = body
        else
          dataMsg = "#{res.statusCode}\n#{body}"

        #send the message for all to see!
        #console.log dataMsg
        robot.messageRoom "##{room}", "#{dataMsg}"





