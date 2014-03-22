# Description:
#   Info about all the nerd beers
#
# Commands:
#   hubot nerdbeers - the known nerdbeers chapters
#   hubot nerdbeers <chapter-id> - details of chapter
#   hubot nerdbeers agenda <chapter-id> - agenda for the chapter
#   hubot okcnerdbeers - shorthand for hubot nerdbeers okc
#   hubot okcnerdbeers agenda - shorthand for hubot nerdbeers agenda okc
#
# Notes:
#

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
  'pit' : {
    id      : 'pit'
    name    : 'Pittsburgh Nerd Beers'
    city    : 'Pittsburgh'
    state   : 'PA'
    url     : null
    api     : null
    status  : 'pending'
  }
}

chapterInfo = (chapterId) ->
  return chapters[chapterId.toLowerCase()]

chapterDetails = (chapterId, full) ->
  deets = []
  chapter = chapterInfo chapterId

  if not chapter?
    deets.push 'No chapter found for chapter id "' + chapterId + '"'
    deets.push 'Try "hubot nerdbeers"'
  else
    deets.push chapter.name + ' (' + chapter.status + ')'
    deets.push 'id: ' + chapter.id
    deets.push 'where: ' + chapter.city + ', ' + chapter.state
    if full
      deets.push 'url: ' + chapter.url unless not chapter.url?
      deets.push 'api: ' + chapter.api unless not chapter.api?

  return deets.join '\n'  

chapterAgenda = (msg, chapterId) ->
  deets = []
  chapter = chapterInfo chapterId

  if not chapter?
    deets.push 'No chapter found for chapter id "' + chapterId + '"!'
    deets.push 'Try "hubot nerdbeers"'
    return deets.join '\n'  

  if not chapter.api?
    return chapter.name + ' does not have an API configured!'

  apiCall msg, chapter.api, (err, body) ->
    if err
      return body

    data = JSON.parse(body)

    if data?
      agenda = [chapter.name + ' Agenda']
      num = 1
      agenda.push 'Topic ' + (num++).toString() + ': ' + d.topic + ' - ' + '(beer) ' + d.beer for d in data
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
