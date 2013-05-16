require 'bling'
request = require "request"
Conductrics = exports

Conductrics.baseUrl = "https://api.conductrics.com"
Conductrics.apiKey = "..."
Conductrics.ownerCode = "..."

_property = (field) -> (val) ->
	if arguments.length is 0
		return switch true
			when field of @properties then @properties[field]
			when field of Conductrics then Conductrics[field]
	else if val is null
		delete @properties[field]
	else @properties[field] = val
	return @

_jsonHandler = (callback) ->
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
	""" .request(sessionId, [opts], url, cb) -> """
	try
		cb = args.pop()
		url = args.pop()
		if args.length > 1
			opts = args.pop()
		unless opts?
			opts = {}
		sessionId = args.pop()
		req =
			method: opts.method ? "GET"
			url: url
			headers: $.extend {
				"x-mpath-apikey": Conductrics.apiKey
				"x-mpath-session": sessionId
			}, opts.headers
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
		request req, _jsonHandler cb
	catch err
		cb err, null

class Conductrics.Agent

	constructor: (@name) ->
		""" new Conductrics.Agent("agent-name") """
		@properties = {}

	apiKey: _property('apiKey')
	baseUrl: _property('baseUrl')
	ownerCode: _property('ownerCode')
	requestLimit: _property('requestLimit')
	requestCount: _property('requestCount')

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

class Conductrics.Administrator
	adminKey: _property 'adminKey'
	ownerCode: _property 'ownerCode'
	baseUrl: _property 'baseUrl'

	constructor: -> @properties = {}

	createApiKey: (args...) ->
		""" .createApiKey(rootKey, rootOwner, email, [ownerCode], callback) """
		callback = args.pop()
		if args.length > 3
			ownerCode = args.pop()
		else
			ownerCode = "owner_" + $.random.string 9
		email = args.pop()
		rootOwner = args.pop()
		rootKey = args.pop()
		_request null, {method: "PUT"}, @agentUrl("create-key", email), callback
	checkLogin: (email, password, callback) ->
		_request null, {
			headers: {
				"x-mpath-email": email
				"x-mpath-password": password
			}
		}, [@baseUrl(), "login"].join("/"), callback


if require.main is module

	assert = require 'assert'

	agent = new Conductrics.Agent("node-agent")
		.apiKey("api-qJJuXpmAuJqYuKzMeXtjUVUt")
		.ownerCode("owner_yuXqselMg")

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

	new Conductrics.Administrator()
		.adminKey("admin_EOJyrYQRCquXJkfwlhoOCiNaQx")
		.ownerCode("owner_yuXqselMg")
		.checkLogin "jesse.dailey+7@gmail.com", "yCXpDqlG", (args...) ->
			console.log "checkLogin response:", args
