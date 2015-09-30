# Description:
#   Hubot will respond with thoughts on the rollout
#
# Commands:
#   hubot rollout (forecast|looking|thoughts|prediction) - hubot will share his thoughts
#
# Notes:
#   Have fun with it.
#
# Author:
#   ryoe

rolloutUrls = [
  'https://www.youtube.com/watch?v=epSrFV2Wtjs#t=48'
  'http://c5.nrostatic.com/sites/default/files/uploaded/Train%20Wreck%20One.gif'
  'http://media.giphy.com/media/mTXSKTk3BsT6w/giphy.gif'
  'http://i.kinja-img.com/gawker-media/image/upload/s--GMvrPnEt--/c_fit,fl_progressive,q_80,w_636/ltppilanfm7rz7rxaupn.gif'
  'http://i.imgur.com/dioqtic.gif'
  'http://33.media.tumblr.com/2e30bcd2314ffd493a981e267b092aca/tumblr_nr7cp1L30f1s373hwo1_250.gif'
  'http://i.imgur.com/66DfQdv.gifv'
  'https://gifcrap.com/g2data/albums/Kids/Kid%20gets%20chased%20by%20a%20rooster.gif'
  'https://pbs.twimg.com/tweet_video/CLA29NBWgAEWbB5.mp4'
  'https://i.imgur.com/f5u2RL5.gifv'
  'http://cdn.gifbay.com/2013/01/football_spike_fail-23002.gif'
  'https://s-media-cache-ak0.pinimg.com/originals/63/bd/75/63bd75afd2c7c17748e4766b541bf9ad.jpg'
  'http://i.imgur.com/ZMOhZEF.gifv'
]

rolloutGreetings =[
  'I\'m hopeful it goes better than this:'
  'My best guess is something like this:'
  'Funny you should ask, but here\'s one possibility:'
  'Survey says!'
]

module.exports = (robot) ->
  robot.respond /(.*)?(rollout|demo) (forecast|looking|thoughts|prediction)/i, (msg) ->
    txt = [
      msg.random rolloutGreetings
      msg.random rolloutUrls      
    ]
    msg.send txt.join '\n'
