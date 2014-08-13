require '../helper'
express = require 'express'
http = require 'http'

describe 'url', ->

  before (done) ->
    # for HTTP Server
    @app = express()
    @app.get '/', (req, res) ->
      res.send '''
<html><head><title>Title</title>
<meta property="og:title" content="Title!" />
<meta property="og:type" content="website" />
<meta property="og:image" content="http://localhost:3000/img.png" />
<meta property="og:url" content="http://localhost:3000/" />
</head><body></body></html>
'''
    @app.get '/empty', (req, res) ->
      html = '<html><head><title></title></head><body></body></html>'
      res.send html
    @server = http.createServer(@app)
    @server.listen 3000, done

  beforeEach (done) ->
    # for Hubot
    @kakashi.scripts = [require('../../')]
    @kakashi.users = [{ id: 'bouzuya', room: 'hitoridokusho'}]
    @kakashi.start().then done, done

  after: ->
    @server.close()

  describe '/', ->
    it 'send "Title" & "http://localhost:3000/img.png"', (done) ->
      sender = { id: 'bouzuya', room: 'bouzuya.net' }
      message = 'http://localhost:3000/'
      @kakashi
        .maxCallCount(2)
        .receive(sender, message)
        .then =>
          expect(@kakashi.send.firstCall.args[1])
            .to.equal('Title')
          expect(@kakashi.send.secondCall.args[1])
            .to.equal('http://localhost:3000/img.png')
        .then((-> done()), done)

  describe '/empty', ->
    it 'throws timeout error', (done) ->
      sender = { id: 'bouzuya', room: 'bouzuya.net' }
      message = 'http://localhost:3000/empty'
      @kakashi
        .receive(sender, message)
        .then (-> done(new Error('test failure'))), (e) ->
          expect(e.message).to.equal('timeout')
          done()

  describe 'HUBOT_URL_IGNORE_PATTERNS ^', ->
    it 'throws timeout error', (done) ->
      original = process.env.HUBOT_URL_IGNORE_PATTERNS
      process.env.HUBOT_URL_IGNORE_PATTERNS = '["^http://localhost"]'
      sender = { id: 'bouzuya', room: 'bouzuya.net' }
      message = 'http://localhost:3000/'
      @kakashi
        .receive(sender, message)
        .then (-> done(new Error('test failure'))), (e) ->
          expect(e.message).to.equal('timeout')
          done()

  describe 'HUBOT_URL_IGNORE_PATTERNS $', ->
    it 'throws timeout error', (done) ->
      original = process.env.HUBOT_URL_IGNORE_PATTERNS
      process.env.HUBOT_URL_IGNORE_PATTERNS = '[":3000/$"]'
      sender = { id: 'bouzuya', room: 'bouzuya.net' }
      message = 'http://localhost:3000/'
      @kakashi
        .receive(sender, message)
        .then (-> done(new Error('test failure'))), (e) ->
          expect(e.message).to.equal('timeout')
          process.env.HUBOT_URL_IGNORE_PATTERNS = original
          done()

  describe 'HUBOT_URL_IGNORE_PATTERNS empty', ->
    it 'send "Title" & "http://localhost:3000/img.png"', (done) ->
      original = process.env.HUBOT_URL_IGNORE_PATTERNS
      process.env.HUBOT_URL_IGNORE_PATTERNS = '[]'
      sender = { id: 'bouzuya', room: 'bouzuya.net' }
      message = 'http://localhost:3000/'
      @kakashi
        .receive(sender, message)
        .then =>
          expect(@kakashi.send.firstCall.args[1])
            .to.equal('Title')
          expect(@kakashi.send.secondCall.args[1])
            .to.equal('http://localhost:3000/img.png')
          process.env.HUBOT_URL_IGNORE_PATTERNS = original
        .then (-> done()), done
