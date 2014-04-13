# Description:
#   Info about all the nerd beers chapters
#
# Dependencies:
#   none
#
# Commands:
#   hubot nerdbeers - the known nerd beers chapters
#   hubot nerdbeers <chapter-id> - details of chapter
#   hubot nerdbeers agenda <chapter-id> - agenda for the chapter
#   hubot okcnerdbeers - shorthand for hubot nerdbeers okc
#   hubot okcnerdbeers agenda - shorthand for hubot nerdbeers agenda okc
#
# Notes:
#   Have fun with it.
#
# Author:
#   ryoe

apiUrl = 'http://nerdbeers.com/api'

chapterDetails = (chapter, full) ->
  deets = []
  deets.push chapter.name

  id = 'id: ' + chapter.id
  id += ' or ' + chapter.alias if chapter.alias.localeCompare(chapter.id) != 0
  deets.push id
  deets.push 'where: ' + chapter.where

  if full
    console.log 'add in "full details" as they become available in the API'

  return deets.join '\n'

chapterAgenda = (msg, chapterId) ->
  #we must choose which one we want to use for realz...
  #url = apiUrl + '/agenda/' + chapterId
  url = apiUrl + '/chapters/' + chapterId + '/agenda'

  apiCall msg, url, (err, body) ->
    if err
      msg.send body
      return

    data = JSON.parse(body)

    if data?
      #agenda = [chapter.name + ' - ' + data.title ]
      agenda = [data.title ]
      agenda.push 'Topic ' + d.id.toString() + ': ' + d.topic + ' - ' + '(beer) ' + d.beer for d in data.topics
      agenda.push 'When: ' + data.date
      agenda.push 'Where: ' + data.where.venue + '\nMap: ' + data.where.link unless not data.where?
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

getChapterInfo = (msg, chapterId, cb) ->
  apiCall msg, apiUrl + '/chapters/' + chapterId, (err, body) ->
    if err
      cb body
      return
    cb chapterDetails JSON.parse(body), true

getChapters = (msg, cb) ->
  apiCall msg, apiUrl + '/chapters', (err, body) ->
    cb JSON.parse(body)

module.exports = (robot) ->
  robot.respond /\bokcnerdbeers\b/i, (msg) ->
    text = msg.message.text

    if text.match(/\bagenda\b/i)
      chapterAgenda msg, 'okc'
    else
      getChapterInfo msg, 'okc', (body) ->
        msg.send body

  robot.respond /\bnerdbeers\b/i, (msg) ->
    userName = msg.message.user.name
    userMentionName = msg.message.user.mention_name ? 'nerdbeersfriend'

    text = msg.message.text
    matches = text.match(/(\bnerdbeers\b){1}(\s*)?(\S*)?(\s*)?(.*)?/i)
    agendaOrCid = matches[3]
    cid = matches[5]

    if not agendaOrCid? and not cid?
      getChapters msg, (body) ->
        chapters = body
        list = []
        list.push chapterDetails c, false for c in chapters
        msg.send 'Here are the Nerd Beers chapters I know about:\n\n' + list.join '\n\n'
        return

    else if agendaOrCid.match(/\bagenda\b/i)
      chapterAgenda msg, cid
    else
      getChapterInfo msg, agendaOrCid, (body) ->
        msg.send body