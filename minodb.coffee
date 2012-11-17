http = require "http"
mongodb = require "mongodb"
express = require "express"


DB_NAME = 'myproject'
DB_COLLECTION = 'default'
PUBLIC_DIRECTORY = true

HTTP_HOST = '0.0.0.0'
HTTP_PORT = 7777

DB_HOST = '127.0.0.1'
DB_PORT = 27017

DEBUG = true


server = new mongodb.Server DB_HOST, DB_PORT, {}

debug_print_query = (query_name, info={}) ->
  if DEBUG
    console.log "DEBUG: query #{query_name}:"
    console.dir info

debug_print_query_result = (query_name, results) ->
  if DEBUG
    console.log "DEBUG: result for query #{query_name}:"
    console.dir results


new mongodb.Db(DB_NAME, server, { safe: true }).open (error, client) ->

  throw error  if error

  collection = new mongodb.Collection(client, DB_COLLECTION)

  console.log "database connected"

  app = express()
  app.configure ->
    app.use express.bodyParser()

  app.get "/", (req, res) ->
    debug_print_query '/'
    res.send 'minodb running'

  app.get "/list", (req, res) ->
    collection.find().toArray (err, results) ->
      debug_print_query_result '/list', results
      res.send JSON.stringify(results)

  app.get "/get/:id?", (req, res) ->
    id = req.params.id
    if id
      debug_print_query '/get', { id: id }
      collection.find({ id: id }, { limit: 1 }).toArray (err, results) ->
        debug_print_query_result '/get', results
        res.send JSON.stringify(results)
    else
      res.send 400, 'missing id for /get/[id]'

  app.post "/put", (req, res) ->
    obj = req.body
    debug_print_query '/put', obj
    collection.update { id: obj.id }, obj, { upsert: true }, (err, client) ->
      if err
        console.warn err.message
        res.send 500, '/put failed'
      else
        res.send ""

  app.post "/drop", (req, res) ->
    console.warn 'DROPPING COLLECTION'
    collection.remove {}, (err, client) ->
      if err
        console.warn err.message
        res.send 500, '/drop failed'
    res.send "collection dropped"

  app.listen HTTP_PORT, HTTP_HOST
