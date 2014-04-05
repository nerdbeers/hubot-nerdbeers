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

chapters = {
  'okc' : {
    id      : 'okc'
    name    : 'OKC Nerd Beers'
    city    : 'Greater Oklahoma City area'
    state   : 'OK'
    url     : 'http://agenda.okcnerdbeers.com/'
    api     : 'http://agenda.okcnerdbeers.com/api'
    status  : 'active'
  }
  'pgh' : {
    id      : 'pgh'
    name    : 'Pittsburgh Nerd Beers'
    city    : 'Pittsburgh'
    state   : 'PA'
    url     : 'https://plus.google.com/u/0/communities/114514661157596581443'
    api     : null
    status  : 'active'
  }
}

aliases = {
  'pit' : 'pgh'
}

chapterInfo = (chapterId) ->
  return chapters[(chapterId + '').toLowerCase()] ? null

chapterDetails = (chapterId, full) ->
  origChapterId = chapterId
  deets = []
  chapter = chapterInfo chapterId

  if not chapter?
    chapterId = aliases[chapterId]
    chapter = chapterInfo chapterId

  if not chapter?
    deets.push 'No chapter found for chapter id "' + origChapterId + '"!'
    deets.push 'Try "hubot nerdbeers" for a list of known nerdbeers.'
  else
    deets.push chapter.name
    deets.push 'where: ' + chapter.city + ', ' + chapter.state

    id = 'id: ' + chapter.id
    alias = a for a of aliases when aliases[a].localeCompare(chapter.id) == 0
    id += ' or ' + alias if alias?

    deets.push id
    if full
      deets.push 'url: ' + chapter.url unless not chapter.url?
      deets.push 'api: ' + chapter.api unless not chapter.api?

  return deets.join '\n'  

chapterAgenda = (msg, chapterId) ->
  origChapterId = chapterId
  deets = []
  chapter = chapterInfo chapterId

  if not chapter?
    chapterId = aliases[chapterId]
    chapter = chapterInfo chapterId

  if not chapter?
    deets.push 'No chapter found for chapter id "' + origChapterId + '"!'
    deets.push 'Try "hubot nerdbeers" for a list of known nerdbeers.'
    msg.send deets.join '\n'
    return

  if not chapter.api?
    msg.send chapter.name + ' does not have an API configured!'
    return

  apiCall msg, chapter.api, (err, body) ->
    if err
      msg.send body
      return

    data = JSON.parse(body)

    if data?
      agenda = [chapter.name + ' - ' + data.title ]
      agenda.push 'Topic ' + d.id.toString() + ': ' + d.topic + ' - ' + '(beer) ' + d.beer for d in data.topics
      agenda.push 'When: ' + data.date
      agenda.push 'Where: ' + data.where.venue + '\nMap: ' + data.where.link
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
  robot.respond /\bokcnerdbeers\b/i, (msg) ->
    text = msg.message.text

    if text.match(/\bagenda\b/i)
      chapterAgenda msg, 'okc'
    else
      msg.send chapterDetails 'okc', true

  robot.respond /\bnerdbeers\b/i, (msg) ->
    userName = msg.message.user.name
    userMentionName = msg.message.user.mention_name ? 'nerdbeersfriend'

    text = msg.message.text
    matches = text.match(/(\bnerdbeers\b){1}(\s*)?(\S*)?(\s*)?(.*)?/i)
    agendaOrCid = matches[3]
    cid = matches[5]

    if not agendaOrCid? and not cid?
      list = []
      list.push chapterDetails c, true for c of chapters
      msg.send 'Here are the Nerd Beers chapters I know about:\n\n' + list.join '\n\n'
      return

    if agendaOrCid.match(/\bagenda\b/i)
      chapterAgenda msg, cid
    else
      msg.send chapterDetails agendaOrCid, true