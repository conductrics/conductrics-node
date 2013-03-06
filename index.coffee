require 'bling'
request = require "request"
Conductrics = exports

Conductrics.baseUrl = "http://api.conductrics.com"
Conductrics.apiKey = "..."
Conductrics.ownerCode = "..."


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
	newRequest = (sessionId, opts, url) ->
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
		return req

	constructor: (@name) ->

	decide: (a...) ->
		""" agent.decide(sessionId, [opts], choices, cb) """
		cb = a.pop()
		choices = a.pop()
		if a.length > 1
			opts = a.pop()
		else
			opts = Object.create null
		sessionId = a.pop()

		request newRequest(sessionId, opts,
			[Conductrics.baseUrl, Conductrics.ownerCode, @name, "decision", choices.length].join "/"
		), jsonHandler (err, obj) ->
			return cb(err, null) if err
			return cb(null, choices[parseInt obj.decision])

	reward: (a...) ->
		""" agent.reward(sessionId, [opts], cb) """
		cb = a.pop()
		if a.length > 1
			opts = a.pop()
		sessionId = a.pop()
		opts = $.extend {
			goalCode: "goal-1"
			value: 1.0
		}, opts
		url = [Conductrics.baseUrl, Conductrics.ownerCode, @name, "goal", opts.goalCode].join "/"
		if opts.value != 1
			url += "?reward=#{opts.value}"
		request newRequest(sessionId, opts, url), jsonHandler (err, obj) ->
			return cb(err, null) if err
			return cb(null, obj.reward)

	expire: (sessionId, cb) ->
		url = [Conductrics.baseUrl, Conductrics.ownerCode, @name, "expire"].join "/"
		request newRequest(sessionId, {}, url), jsonHandler (err, obj) ->
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

