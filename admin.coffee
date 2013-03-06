Conductrics = require "./index"
request = require "request"

class Conductrics.AdminAgent extends Conductrics.Agent
	createApiKey: (rootKey, rootOwner, email, ownerCode, callback) ->
		if not ownerCode
			ownerCode = "owner_" + $.random.string 9
		request(
			method: "PUT"
			url: [Conductrics.baseUrl,ownerCode,"create-key",email].join "/"
			headers:
				"x-mpath-apikey": rootKey
				"x-mpath-owner": rootOwner
		, Conductrics.Agent.jsonHandler callback)
	checkLogin: (email, password, callback) ->
		request(
			method: "GET"
			url: [Conductrics.baseUrl,"login"].join "/"
			headers:
				"x-mpath-email": email
				"x-mpath-password": password
		, Conductrics.Agent.jsonHandler callback)
