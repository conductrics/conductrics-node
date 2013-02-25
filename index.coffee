require "bling"
request = require "request"

defaultHandler = (callback) ->
	(err, resp, body) ->
		return callback(err, null) if err
		try
			obj = JSON.parse(body)
			return callback obj.err, null if "err" of obj
			return callback obj.error, null if "error" of obj
			return callback null, obj
		catch err
			return callback err, null

exports.baseUrl = "http://api.conductrics.com"
exports.apiKey = "..."
exports.ownerCode = "..."

class Promise
	constructor: (f) ->
		@q = []
		f (a...) =>
			@result = a
			g(a...) for g in @q
	then: (cb) ->
		if 'result' of @ then cb(@result...)
		else @q.push cb

class exports.Agent
	constructor: (@name) ->
	decide: (sessionId, choices...) ->
		return new Promise (cb) ->
			request(
				method: "GET"
				url: [baseUrl, ownerCode, agentCode, "decision"].join "/"
				qs:
					point: pointCode
				headers:
					"x-mpath-apikey": apikey
					"x-mpath-session": sessionCode
			, defaultHandler cb)

	reward: (sessionId, value = 1.0, goalCode = "goal-1") ->
		return new Promise (cb) -> cb()

if require.main is module
	p = new Promise (cb) ->
		$.delay 300, cb
	
	p.then(-> $.log "done!")
	
	exports.apiKey = "api-DfEfOmMFMXJCVAJFwRwXvgLk"
	exports.ownerCode = "

"""
exports.init = (baseUrl) ->
	getDecisions: (apikey, sessionCode, ownerCode, agentCode, pointCode, callback) ->
		request(
			method: "GET"
			url: [baseUrl, ownerCode, agentCode, "decision"].join "/"
			qs:
				point: pointCode
			headers:
				"x-mpath-apikey": apikey
				"x-mpath-session": sessionCode
		, defaultHandler callback)
	sendReward: (apikey, sessionCode, ownerCode, agentCode, goalCode, callback) ->
		request(
			method: "POST"
			url: [baseUrl, ownerCode, agentCode, "goal", goalCode].join "/"
			headers:
				"x-mpath-apikey": apikey
				"x-mpath-session": sessionCode
		, defaultHandler callback)
	expireSession: (apikey, ownerCode, sessionCode, callback) ->
		request(
			method: "GET"
			url: [baseUrl, ownerCode, agentCode, "expire"].join "/"
			headers:
				"x-mpath-apikey": apikey
				"x-mpath-session": sessionCode
		, defaultHandler callback)
	createAgent: (apikey, ownerCode, agentCode, agentJson, callback) ->
		request(
			method: "PUT"
			url: [baseUrl, ownerCode, agentCode].join "/"
			headers:
				"x-mpath-apikey": apikey
			json: agentJson
		, defaultHandler callback)
	createApiKey: (rootKey, rootOwner, email, ownerCode, callback) ->
		if not ownerCode
			ownerCode = "owner_" + $.random.string 9
		request(
			method: "PUT"
			url: [baseUrl,ownerCode,"create-key",email].join "/"
			headers:
				"x-mpath-apikey": rootKey
				"x-mpath-owner": rootOwner
		, defaultHandler callback)
	checkLogin: (email, password, callback) ->
		request(
			method: "GET"
			url: [baseUrl,"login"].join "/"
			headers:
				"x-mpath-email": email
				"x-mpath-password": password
		, defaultHandler callback)
"""
