require "bling"
request = require "request"

defaultHandler = (callback) ->
	(err, resp, body) ->
		$.log "mpath-client response: #{err} #{body}"
		return callback(err, null) if err
		try
			obj = JSON.parse(body)
			return callback obj.err, null if "err" of obj
			return callback obj.error, null if "error" of obj
			return callback null, obj
		catch err
			return callback err, null

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
			ownerCode = $.random.string(12)
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
