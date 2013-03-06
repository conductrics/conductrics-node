require 'bling'
request = require "request"
Conductrics = exports

jsonHandler = (callback) ->
	(err, resp, body) ->
		return callback(err, null) if err
		try
			obj = JSON.parse(body)
			return callback obj.err, null if "err" of obj
			return callback obj.error, null if "error" of obj
			return callback null, obj
		catch err
			return callback err, null

Conductrics.baseUrl = "http://api.conductrics.com"
Conductrics.apiKey = "..."
Conductrics.ownerCode = "..."

getSession = $.memoize (id) ->
	id: id
	features: null
	segment: null

newRequest = (sessionId, url) ->
	session = getSession(sessionId)
	req =
		method: "GET"
		url: url
		headers:
			"x-mpath-apikey": Conductrics.apiKey
			"x-mpath-session": session.id
	if 'ip' of session
		req.headers['x-mpath-ip'] = session.ip
	if 'ua' of session
		req.headers['x-mpath-ua'] = session.ua
	if session.segment?
		req.headers['x-mpath-segment'] = session.segment
	if session.features?
		req.headers['x-mpath-features'] = ("#{k}:#{parseFloat(v).toFixed 2}" for k,v of session.features).join ","
	return req


class exports.Agent
	constructor: (@name) ->
	setRemoteIP: (sessionId, ip) -> getSession(sessionId).ip = ip
	setUserAgent: (sessionId, ua) -> getSession(sessionId).ua = ua
	setFeature: (sessionId, feature, value = 1) -> (getSession(sessionId).features or= {})[feature] = value
	setSegment: (sessionId, segment) -> getSession(sessionId).segment = segment
	decide: (sessionId, choices, cb) ->
		request newRequest(sessionId,
			[Conductrics.baseUrl, Conductrics.ownerCode, @name, "decision", choices.length].join "/"
		), jsonHandler (err, obj) ->
			return cb(err, null) if err
			return cb(null, choices[parseInt obj.decision])
	reward: (sessionId, opts, cb) ->
		if $.is "function", opts
			cb = opts
			opts = null
		opts = $.extend {
			goalCode: "goal-1"
			value: 1.0
		}, opts
		url = [Conductrics.baseUrl, Conductrics.ownerCode, @name, "goal", opts.goalCode].join "/"
		if opts.value != 1
			url += "?reward=#{opts.value}"
		request newRequest(sessionId, url), jsonHandler (err, obj) ->
			return cb(err, null) if err
			return cb(null, obj.reward)
	expire: (sessionId, cb) ->
		url = [Conductrics.baseUrl, Conductrics.ownerCode, @name, "expire"].join "/"
		request newRequest(sessionId, url), jsonHandler (err, obj) ->
			return cb(err, null) if err
			return cb(null, obj)

if require.main is module

	assert = require 'assert'

	Conductrics.apiKey = "api-HFrPvhjnhVufRXtCGOIzejSW"
	Conductrics.ownerCode = "owner_HJJnKxAdm"

	a = new exports.Agent("node-agent")
	sessionId = $.random.string 16

	a.decide sessionId, ["a", "b"], (err, decision) ->
		assert decision in ['a', 'b']
		unless err
			a.reward sessionId, { value: 1.2 }, (err, result) ->
				assert result is 1.2

"""
exports.init = (baseUrl) ->
	createApiKey: (rootKey, rootOwner, email, ownerCode, callback) ->
		if not ownerCode
			ownerCode = "owner_" + $.random.string 9
		request(
			method: "PUT"
			url: [baseUrl,ownerCode,"create-key",email].join "/"
			headers:
				"x-mpath-apikey": rootKey
				"x-mpath-owner": rootOwner
		, jsonHandler callback)
	checkLogin: (email, password, callback) ->
		request(
			method: "GET"
			url: [baseUrl,"login"].join "/"
			headers:
				"x-mpath-email": email
				"x-mpath-password": password
		, jsonHandler callback)
"""
