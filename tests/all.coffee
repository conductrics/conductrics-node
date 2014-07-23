assert = require 'assert'
Conductrics = require('../src/index.coffee')
$.extend Conductrics, require('../src/admin.coffee')

test_agent = -> new Conductrics.Agent("test-agent")
	.apiKey("api-tpxxhxZkzjIoAtDTGgajpHtJ")
	.ownerCode("owner_hRPRBZehV")

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

describe "Agent", ->
	describe "has property", ->
		it "apiKey", -> assert 'apiKey' of (new Conductrics.Agent)
		it "baseUrl", -> assert 'baseUrl' of (new Conductrics.Agent)
		it "ownerCode", -> assert 'ownerCode' of (new Conductrics.Agent)
	it "can be created and configured", ->
		agent = test_agent()
	it "computes agentUrl", ->
		agent = test_agent()
		assert.equal agent.agentUrl("one","two","three"), agent.baseUrl() + "/owner_hRPRBZehV/test-agent/one/two/three"
	describe "decision making", ->
		it "works", (done) ->
			agent = test_agent()
			sessionId = $.random.string 16
			agent.decide sessionId, ['a', 'b'], (err, decision) ->
				assert decision in ['a', 'b']
				done()
		it "works with a features list", (done) ->
			agent = test_agent()
			sessionId = $.random.string 16
			agent.decide sessionId, {
				features: [ 'male', 'vip' ]
			}, ['a', 'b'], (err, decision) ->
				assert decision in ['a', 'b']
				done()
		it "works with feature values", (done) ->
			agent = test_agent()
			sessionId = $.random.string 16
			agent.decide sessionId, {
				features: { male: 1, age: 34 }
			}, ['a', 'b'], (err, decision) ->
				assert decision in ['a', 'b']
				done()
		it "works with segments", (done) ->
			agent = test_agent()
			sessionId = $.random.string 16
			agent.decide sessionId, {
				segment: "vip"
			}, ['a', 'b'], (err, decision) ->
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

