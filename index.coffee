require 'bling'
request = require "request"
Conductrics = exports

Conductrics.baseUrl = "http://api.conductrics.com"
Conductrics.apiKey = "..."
Conductrics.ownerCode = "..."

property = (field) -> (val) ->
	if arguments.length is 0
		return switch true
			when field of @properties then @properties[field]
			when field of Conductrics then Conductrics[field]
	else if val is null
		delete @properties[field]
	else @properties[field] = val
	return @

class Conductrics.Agent
	@jsonHandler = jsonHandler = (callback) ->
		(err, resp, body) ->
			return callback(err, null) if err
			try
				obj = JSON.parse(body)
				return callback obj.err, null if "err" of obj
				return callback obj.error, null if "error" of obj
				return callback null, obj
			catch err
				return callback err, null
	_request = (args...) ->
		""" _request(sessionId, [opts], url, cb) -> """
		try
			cb = args.pop()
			url = args.pop()
			if args.length > 1
				opts = args.pop()
			unless opts?
				opts = {}
			sessionId = args.pop()
			req =
				method: "GET"
				url: url
				headers:
					"x-mpath-apikey": Conductrics.apiKey
					"x-mpath-session": sessionId
			if 'ip' of opts
				req.headers['x-mpath-ip'] = opts.ip
			if 'ua' of opts
				req.headers['x-mpath-ua'] = opts.ua
			if opts.segment?
				req.headers['x-mpath-segment'] = opts.segment
			if opts.features?
				req.headers['x-mpath-features'] = switch $.type opts.features
					when 'object' then ("#{k}:#{parseFloat(v).toFixed 2}" for k,v of opts.features).join ","
					when 'array','bling' then opts.features.join ","
			request req, jsonHandler cb
		catch err
			cb err, null

	constructor: (@name) ->
		""" new Conductrics.Agent("agent-name") """
		@properties = {
			requestLimit: 10 # max. concurrent requests
			requestCount: 0  # current concurrent requests
		}

	apiKey: property('apiKey')
	baseUrl: property('baseUrl')
	ownerCode: property('ownerCode')
	requestLimit: property('requestLimit')
	requestCount: property('requestCount')

	agentUrl: (parts...) ->
		[@baseUrl(), @ownerCode(), @name].concat(parts).join "/"

	decide: (a...) ->
		"""
		agent.decide(sessionId, [opts], choices, cb)

		opts:
		 - ip: (optional, string) the remote IP address associated with the session, "123.45.67.8"
		 - ua: (optional, string) the remote User Agent
		 - segment: (optional, string) like, 'aerospace' or 'goverment', any label you determine.
		 - features: (optional, array or object) either a list of tags like, ['male','young']
		   - or, an object with numeric values: { age: 0.33, income: 0.93 }
		"""
		cb = a.pop()
		choices = a.pop()
		opts = if a.length > 1 then a.pop() else {}
		sessionId = a.pop()

		_request sessionId, opts, @agentUrl("decision", choices.length), (err, obj) ->
			return cb(err, choices[0]) if err
			return cb(null, choices[parseInt obj.decision])

	reward: (a...) ->
		"""
		agent.reward(sessionId, [opts], cb)

		opts:
		 - goalCode: (optional, string) which 
		 - value: (number) how much
		"""
		cb = a.pop()
		opts = $.extend {
			goalCode: "goal-1"
			value: 1.0
		}, if a.length > 1 then a.pop() else null
		sessionId = a.pop()
		url = @agentUrl "goal", opts.goalCode
		if opts.value != 1
			url += "?reward=#{opts.value}"
		_request sessionId, opts, url, (err, obj) ->
			return cb(err, 0) if err
			return cb(null, obj.reward)

	expire: (sessionId, cb) ->
		""" agent.expire(sessionId, cb) """
		_request sessionId, @agentUrl("expire"), (err, obj) ->
			return cb(err, null) if err
			return cb(null, obj)

if require.main is module

	assert = require 'assert'

	Conductrics.apiKey = "api-HFrPvhjnhVufRXtCGOIzejSW"
	Conductrics.ownerCode = "owner_HJJnKxAdm"

	agent = new Conductrics.Agent("node-agent")

	do (sessionId = $.random.string 16) ->
		agent.decide sessionId, ["a", "b"], (err, decision) ->
			assert decision in ['a', 'b']
			unless err
				agent.reward sessionId, (err, result) ->
					assert.equal result, 1.0
					unless err
						agent.expire sessionId, (err, result) ->

	do (sessionId = $.random.string 16) ->
		agent.decide sessionId, ["a", "b"], (err, decision) ->
			assert decision in ['a', 'b']
			unless err
				agent.reward sessionId, { value: 1.2 }, (err, result) ->
					assert.equal result, 1.2
					unless err
						agent.expire sessionId, (err, result) ->

	do (sessionId = $.random.string 16) ->
		agent.decide sessionId, {
			features: {
				young: 1
				male: 1
			},
			segment: 'aerospace'
		}, [ "a", "b"], (err, decision) ->
			assert decision in ['a', 'b']
			unless err
				agent.reward sessionId, { value: 2.1 }, (err, result) ->
					assert.equal result, 2.1
					unless err
						agent.expire sessionId, (err, result) ->

	do (sessionId = $.random.string 16) ->
		agent.decide sessionId, {
			features: ['urban','female']
			segment: 'aerospace'
		}, [ "a", "b"], (err, decision) ->
			assert decision in ['a', 'b']
			unless err
				agent.reward sessionId, { value: 2.1 }, (err, result) ->
					assert.equal result, 2.1
					unless err
						agent.expire sessionId, (err, result) ->

