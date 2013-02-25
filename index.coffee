request = require("request")
require "../common"

defaultHandler = (callback) ->
	(err, resp, body) ->
		return callback(err, null) if err
		try return callback(null, JSON.parse(body))
		catch err
			return callback(err, null)

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
	createApiKey: (email, ownerCode, callback) ->
		if not ownerCode
			ownerCode = $.random.string(12)
		request(
			method: "PUT"
			url: [baseUrl,ownerCode,"create-key",email].join "/"
		, defaultHandler callback)
