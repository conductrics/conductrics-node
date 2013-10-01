{ classy_property, request } = require "./index"

class exports.Administrator
	constructor: ->
		@properties = {}

	apiKey: classy_property 'apiKey'
	ownerCode: classy_property 'ownerCode'
	baseUrl: classy_property 'baseUrl'

	createApiKey: (args...) ->
		"""
			.createApiKey(rootKey, rootOwner, email, [ownerCode], callback)
			# note: it's very likely that your api key does not have this authority
		"""
		callback = args.pop()
		if args.length > 3
			ownerCode = args.pop()
		else
			ownerCode = "owner_" + $.random.string 9
		email = args.pop()
		rootOwner = args.pop()
		rootKey = args.pop()
		request @apiKey(), null, {method: "PUT"}, @agentUrl("create-key", email), callback

	checkLogin: (email, password, callback) ->
		request @apiKey(), null, {
			headers: {
				"x-mpath-email": email
				"x-mpath-password": password
			}
		}, [@baseUrl(), "login"].join("/"), (err, data) ->
			callback !err

if require.main is module
	log = $.logger "[Admin]"
	new exports.Administrator()
		.apiKey("admin_EOJyrYQRCquXJkfwlhoOCiNaQx")
		.ownerCode("owner_yuXqselMg")
		.checkLogin "jesse.dailey+7@gmail.com", "yCXpDqlG", (ok) ->
			$.log "checkLogin response:", ok
	
