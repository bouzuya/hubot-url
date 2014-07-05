require '../helper'
express = require 'express'

describe 'url', ->
  before (done) ->
    @server = express()
    @server.get '/', (req, res) ->
      html = '''
<html><head><title>Title</title>
<meta property="og:title" content="Title!" />
<meta property="og:type" content="website" />
<meta property="og:image" content="http://localhost:3000/img.png" />
<meta property="og:url" content="http://localhost:3000/" />
</head><body></body></html>
'''
      res.send html
    @server.get '/empty', (req, res) ->
      html = '<html><head><title></title></head><body></body></html>'
      res.send html
    @server.listen(3000)
    done()

  beforeEach (done) ->
    @driver.start
      scripts: [require('../../')]
      users: [{ id: '1', name: 'bouzuya', room: 'bouzuya.net'}]
    .then done, done

  context '/', ->
    it 'send "Title http://localhost:3000/img.png"', (done) ->
      message = 'http://localhost:3000/'
      @driver
        .receiveMessage(@driver.users[0], message)
        .then (options) ->
          expect(options.name).to.equal('send')
          expect(options.strings[0])
            .to.equal('Title http://localhost:3000/img.png')
        .then (-> done()), done

  describe '/empty', ->
    it 'throws timeout error', (done) ->
      message = 'http://localhost:3000/empty'
      @driver
        .receiveMessage(@driver.users[0], message)
        .then (-> done(new Error('test failure'))), (e) ->
          expect(e.message).to.equal('timeout')
          done()

  describe 'HUBOT_URL_IGNORE_PATTERNS ^', ->
    it 'throws timeout error', (done) ->
      original = process.env.HUBOT_URL_IGNORE_PATTERNS
      process.env.HUBOT_URL_IGNORE_PATTERNS = '["^http://localhost"]'
      message = 'http://localhost:3000/'
      @driver
        .receiveMessage(@driver.users[0], message)
        .then (-> done(new Error('test failure'))), (e) ->
          expect(e.message).to.equal('timeout')
          process.env.HUBOT_URL_IGNORE_PATTERNS = original
          done()

  describe 'HUBOT_URL_IGNORE_PATTERNS $', ->
    it 'throws timeout error', (done) ->
      original = process.env.HUBOT_URL_IGNORE_PATTERNS
      process.env.HUBOT_URL_IGNORE_PATTERNS = '[":3000/$"]'
      message = 'http://localhost:3000/'
      @driver
        .receiveMessage(@driver.users[0], message)
        .then (-> done(new Error('test failure'))), (e) ->
          expect(e.message).to.equal('timeout')
          process.env.HUBOT_URL_IGNORE_PATTERNS = original
          done()

  describe 'HUBOT_URL_IGNORE_PATTERNS empty', ->
    it 'send "Title http://localhost:3000/img.png"', (done) ->
      original = process.env.HUBOT_URL_IGNORE_PATTERNS
      process.env.HUBOT_URL_IGNORE_PATTERNS = '[]'
      message = 'http://localhost:3000/'
      @driver
        .receiveMessage(@driver.users[0], message)
        .then (options) ->
          expect(options.name).to.equal('send')
          expect(options.strings[0])
            .to.equal('Title http://localhost:3000/img.png')
          process.env.HUBOT_URL_IGNORE_PATTERNS = original
        .then (-> done()), done
