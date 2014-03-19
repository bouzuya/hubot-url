// Description
//   fetch url, respond title and og:image
//
// Dependencies:
//   "scraper": "0.0.9"
//
// Configuration:
//   HUBOT_URL_IGNORE_PATTERNS
//
// Commands:
//   ^https?://.*$ - respond title and og:image
//
// Author:
//   bouzuya <bouzuya@gmail.com>

var scraper = require('scraper');

var parseOgp = function($) {
  var ogp = {};
  $('meta').filter(function() {
    var property = $(this).attr('property');
    return /^og:.*$/.test(property);
  }).map(function() {
    var e = $(this);
    return {
      property: e.attr('property'),
      content: e.attr('content')
    };
  }).each(function() {
    // reduce ...
    var e = $(this).get(0);
    ogp[e.property.replace(/^og:/, '')] = e.content;
  });
  return ogp;
};

module.exports = function(robot) {

  robot.hear(/^(https?:\/\/.*)$/, function(msg) {
    var url = msg.match[1];

    var patterns = process.env.HUBOT_URL_IGNORE_PATTERNS || '[]';
    patterns = JSON.parse(patterns);
    patterns = patterns.map(function(p) {
      return new RegExp(p);
    });

    if (patterns.some(function(p) { return p.test(url); })) {
      return;
    }

    // msg.send('fetching... ' + url);
    scraper(url, function(err, $) {
      if (err) throw err;
      var title = $('title').text();
      var ogp = parseOgp($);
      var t = title || ogp.title || '';
      var i = ogp.image || '';
      if (t !== '' || t !== '') {
        msg.send(t + ' ' + i);
      }
    });
  });
};

