# Description:
#   Perform maintenance tasks on the  http://www.nerdbeers.com/ via API calls
#
# Dependencies:
#   None
#
# Commands:
#   hubot vacuum - vacuum the NerdBeers db
#   hubot clear logs - clear the NerdBeers visitor log
#   hubot maint help - list the hubot maint commands
#   hubot nb team - list the team members who can perform maintenance tasks
#
# Configuration:
#   NB_API_TOKEN: required
#   NB_SLACK_API_TOKEN: required
#
# Notes:
#   Have fun with it.
#
# Author:
#   ryoe
nbApiUrl      = 'http://www.nerdbeers.com/api/'
nbApiToken    = process.env.NB_API_TOKEN || null
slackApiUrl   = 'https://slack.com/api/'
slackApiToken = process.env.NB_SLACK_API_TOKEN || null

allowedUsers  = []

help = [
  'hubot vacuum - vacuum the NerdBeers db'
  'hubot nb vacuum - vacuum the NerdBeers db'
  'hubot clear logs - clear the NerdBeers visitor log'
  'hubot nb clear logs - clear the NerdBeers visitor log'
  'hubot maint help - list the hubot maint commands'
  'hubot nb maint help - list the hubot maint commands'
]

cleanLogs = (msg) ->
  postToNerdbeers msg, 'clearmetrics'

vacuumDb = (msg) ->
  postToNerdbeers msg, 'vacuum'

postToNerdbeers = (msg, action) ->
  userName = msg.message.user.mention_name || msg.message.user.name
  allowed = (name for name in allowedUsers when userName.toUpperCase() == name.toUpperCase())

  unless allowed.length == 1 || userName == "Shell"
    msg.send "Sorry, @#{userName}. But you're not allowed to do that!"
    return

  tokenErrors = []
  unless nbApiToken?
    tokenErrors.push '* NB_API_TOKEN environment variable not set for NerdBeers API'

  unless slackApiToken?
    tokenErrors.push '* NB_SLACK_API_TOKEN environment variable not set for Slack API'

  unless tokenErrors.length == 0
    msg.send tokenErrors.join '\n'
    return

  url = "#{nbApiUrl}robots/#{action}"
  auth = "Token token=#{nbApiToken}"
  console.log auth
  msg.http("#{url}")
    .headers(Authorization: auth)
    .post() (err, res, body) ->
      if err
        msg.send "#{err}"
        return

      unless res.statusCode == 204
        msg.send "statusCode: #{res.statusCode}\n#{body}"

listTeam = (msg) ->
  tokenErrors = []

  unless slackApiToken?
    tokenErrors.push '* NB_SLACK_API_TOKEN environment variable not set for Slack API'

  unless tokenErrors.length == 0
    msg.send tokenErrors.join '\n'
    return

  msg.http("#{slackApiUrl}users.list?token=#{slackApiToken}")
    .post() (err, res, body) ->
      if err
        msg.send "#{err}"
        return

      if res.statusCode == 200
        data = JSON.parse(body)
        if !data.ok
          msg.send "#{data.error}"
        else
          deets = ['*The team*']
          deets.push "#{d.profile.real_name} (#{d.name})" for d in data.members
          allowedUsers = []
          allowedUsers.push "#{d.name}" for d in data.members
          msg.send deets.join '\n - '
      else
        msg.send "statusCode: #{res.statusCode}\n#{body}"

getAllowedUsers = (robot) ->
  unless slackApiToken?
    return

  robot.http("#{slackApiUrl}users.list?token=#{slackApiToken}")
    .post() (err, res, body) ->
      if err
        robot.logger.error.send "#{err}"
        return

      if res.statusCode == 200
        data = JSON.parse(body)
        if !data.ok
          robot.logger.error "#{data.error}"
        else
          allowedUsers = []
          allowedUsers.push "#{d.name}" for d in data.members
          console.log allowedUsers
      else
        robot.logger.error "statusCode: #{res.statusCode}\n#{body}"

module.exports = (robot) ->
  unless nbApiToken?
    robot.logger.error 'WARNING: NB_API_TOKEN environment variable not set for NerdBeers API'

  unless slackApiToken?
    robot.logger.error 'WARNING: NB_SLACK_API_TOKEN environment variable not set for Slack API'

  # set the allowed users array...
  getAllowedUsers robot

  robot.respond /(nb |nerdbeers )?team/i, (msg) ->
    listTeam msg

  robot.respond /(nb |nerdbeers )?maint(enance)? help( .*)?/i, (msg) ->
    msg.send help.join '\n'

  robot.respond /(nb |nerdbeers )?(clear|clean|empty)( )?(logs|metrics)( .*)?/i, (msg) ->
    cleanLogs msg

  robot.respond /(nb |nerdbeers )?(db )?(vacuum|vaccum)( db)?( .*)?/i, (msg) ->
    vacuumDb msg
