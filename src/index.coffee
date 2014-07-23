$ = require 'bling'
request = require "request"
Conductrics = exports

$.extend Conductrics,
	baseUrl: "https://api.conductrics.com"
	apiKey: "..."
	ownerCode: "..."

Conductrics.classy_property = classy_property = (field) -> (val) ->
	if arguments.length is 0
		return switch true
			when field of @properties then @properties[field]
			when field of Conductrics then Conductrics[field]
			else null
	else if val is null then delete @properties[field]
	else @properties[field] = val
	@

Conductrics.request = (args...) ->
	""" .request(apiKey, sessionId, [opts], url, cb) - cb gets err, json-parsed-response """
	try
		cb = args.pop()
		url = args.pop()
		opts = if args.length > 2 then args.pop() else {}
		sessionId = args.pop()
		apiKey = args.pop()
		req =
			method: opts.method ? "GET"
			url: url
			headers: $.extend {
				"x-mpath-apikey": apiKey
				"x-mpath-session": sessionId
			}, opts.headers
		if 'ip' of opts
			req.headers['x-mpath-ip'] = opts.ip
		if 'ua' of opts
			req.headers['x-mpath-ua'] = opts.ua
		if 'segment' of opts
			req.headers['x-mpath-segment'] = opts.segment
		if 'features' of opts
			req.headers['x-mpath-features'] = switch $.type opts.features
				when 'object' then ("#{k}:#{parseFloat(v).toFixed 2}" for k,v of opts.features).join ","
				when 'array','bling' then opts.features.join ","
		request req, (err, resp, body) ->
			return cb(err, null) if err
			try
				obj = JSON.parse body
				return switch
					when "err" of obj then cb obj.err, null
					when "error" of obj then cb obj.error, null
					else cb null, obj
			catch err
				return cb err, null
	catch err
		return cb err, null

class Conductrics.Agent
	constructor: (@name) ->
		""" new Conductrics.Agent("agent-name") """
		@properties = {}

	apiKey: classy_property 'apiKey'
	baseUrl: classy_property 'baseUrl'
	ownerCode: classy_property 'ownerCode'

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

		Conductrics.request @apiKey(), sessionId, opts, @agentUrl("decision", choices.length), (err, obj) ->
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
		Conductrics.request @apiKey(), sessionId, opts, url, (err, obj) ->
			return cb(err, 0) if err
			return cb(null, obj.reward)

	expire: (sessionId, cb) ->
		""" agent.expire(sessionId, cb) """
		Conductrics.request @apiKey(), sessionId, @agentUrl("expire"), (err, obj) ->
			return cb(err, null) if err
			return cb(null, obj)

