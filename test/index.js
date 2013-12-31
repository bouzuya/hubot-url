var express = require('express');
var coffeeScript = require('coffee-script');
var hubot = require('hubot');
var expect = require('chai').expect;

describe('', function() {
  var server;
  var robot;

  before(function(done) {
    var server = express();
    server.get('/', function(req, res) {
      var html = '';
      html += '<html><head><title>Title</title>';
      html += '<meta property="og:title" content="Title!" />';
      html += '<meta property="og:type" content="website" />';
      html += '<meta property="og:image" content="http://localhost:3000/img.png" />';
      html += '<meta property="og:url" content="http://localhost:3000/" />';
      html += '</head><body></body></html>';
      res.send(html);
    });
    server.listen(3000);

    var adapter = 'mock-adapter';
    var httpd = true;
    robot = new hubot.Robot(null, adapter, httpd);
    robot.adapter.on('connected', function() {
      require('../')(robot);
      done();
    });
    robot.run();
  });

  after(function(done) {
    robot.shutdown();
    done();
  });

  describe('', function() {
    it('works', function(done) {
      var message = 'http://localhost:3000/';
      robot.adapter.on('send', function(envelope, strings) {
        expect(strings[0]).to.equal('Title http://localhost:3000/img.png');
        done();
      });
      robot.adapter.receive(new hubot.TextMessage('', message));
    });
  });

});

