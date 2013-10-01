assert = require 'assert'
Conductrics = require('../index.coffee')
$.extend Conductrics, require('../admin.coffee')

describe "properties", ->
	it "inherit the default from the module itself", ->
		assert.equal (new Conductrics.Agent).apiKey(), Conductrics.apiKey
	it "can be over-ridden", ->
		a = new Conductrics.Agent()
		a.apiKey("magic")
		assert.equal a.apiKey(), "magic"
	it "does not leak into the defaults", ->
		a = new Conductrics.Agent()
		a.apiKey("magic")
		assert.equal a.apiKey(), "magic"
		b = new Conductrics.Agent()
		assert.equal b.apiKey(), Conductrics.apiKey

test_agent = -> new Conductrics.Agent("test-agent")
	.apiKey("api-tpxxhxZkzjIoAtDTGgajpHtJ")
	.ownerCode("owner_hRPRBZehV")

describe "Agent", ->
	describe "has property:", ->
		it "apiKey", -> assert 'apiKey' of (new Conductrics.Agent)
		it "baseUrl", -> assert 'baseUrl' of (new Conductrics.Agent)
		it "ownerCode", -> assert 'ownerCode' of (new Conductrics.Agent)
	it "can be created and configured", ->
		agent = test_agent()
	it "computes agentUrl", ->
		agent = test_agent()
		assert.equal agent.agentUrl("one","two","three"), agent.baseUrl() + "/owner_hRPRBZehV/test-agent/one/two/three"
	it "makes decisions", (done) ->
		agent = test_agent()
		sessionId = $.random.string 16
		agent.decide sessionId, ['a', 'b'], (err, decision) ->
			assert decision in ['a', 'b']
			done()
	it "sends rewards", (done) ->
		agent = test_agent()
		sessionId = $.random.string 16
		agent.decide sessionId, ['a', 'b'], (err, decision) ->
			assert decision in ['a', 'b']
			unless err
				agent.reward sessionId, (err, result) ->
					assert.equal result, 1.0
					done()
	it "expires sessions", (done) ->
		agent = test_agent()
		sessionId = $.random.string 16
		agent.decide sessionId, ['a', 'b'], (err, decision) ->
			assert decision in ['a', 'b']
			unless err
				agent.reward sessionId, (err, result) ->
					assert.equal result, 1.0
					agent.expire sessionId, (err) ->
						assert !err
						done()

