# Description
#   fetch url, respond title and og:image
#
# Dependencies:
#   "cheerio": "0.17.0"
#
# Configuration:
#   HUBOT_URL_IGNORE_PATTERNS
#
# Commands:
#   ^https?://.*$ - respond title and og:image
#
# Author:
#   bouzuya <m@bouzuya.net>

cheerio = require 'cheerio'

parseOgp = ($) ->
  ogp = {}
  $('meta')
    .filter ->
      e = $(@)
      property = e.attr 'property'
      /^og:.*$/.test property
    .map ->
      e = $(@)
      {
        property: e.attr('property').replace(/^og:/, '')
        content: e.attr 'content'
      }
    .each ->
      ogp[@property] = @content
  ogp

module.exports = (robot) ->

  robot.hear /^(https?:\/\/.*)$/, (msg) ->

    url = msg.match[1]

    patterns = process.env.HUBOT_URL_IGNORE_PATTERNS or '[]'
    patterns = JSON.parse patterns
    patterns = patterns.map (p) -> new RegExp p
    return if patterns.some (p) -> p.test(url)

    msg
      .http url
      .get() (err, res, body) ->
        throw err if err
        $ = cheerio.load body
        title = $('title').text()
        ogp = parseOgp $
        t = title or ogp.title or null
        i = ogp.image or null
        msg.send(t) if t?
        msg.send(i) if i?
