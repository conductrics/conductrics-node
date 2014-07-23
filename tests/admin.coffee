assert = require 'assert'
Conductrics = require('../src/admin.coffee')

describe "Administrator", ->
	describe "has property", ->
		it "apiKey", -> assert 'apiKey' of (new Conductrics.Administrator)
		it "baseUrl", -> assert 'baseUrl' of (new Conductrics.Administrator)
		it "ownerCode", -> assert 'ownerCode' of (new Conductrics.Administrator)
