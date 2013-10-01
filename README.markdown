Conductrics API
---------------

# Installation

    npm install conductrics-api

# Usage

    Conductrics = require("conductrics-api")
    agent = new Conductrics.Agent("my-agent-name")
      .apiKey("my-api-key")
      .ownerCode("my-owner-code")

    # 1. Make decisions.
    agent.decide sessionId, [ 'a', 'b', 'c'] , (err, decision) ->
      assert decision in [ 'a', 'b', 'c' ]

    # 2. Send rewards.
    agent.reward sessionId, 1.2, (err, result) ->
      assert result is 1.2

    # 3. Profit (literally)

	Agents are created on the server automatically when they are used
	by code, and they attempt to mutate themselves in order to answer
	queries that change over time.

	For instance, if you were calling `agent.decide ['a','b']` for a
	while, but added a third option: 'c', the agent would mutate itself in
	order to learn about 'c', without losing what it has learned about
	'a' and 'b'.

	Similarly, if option 'c' expired for some reason and you stopped
	passing it to the API, it would not be considered eligible for selection,
	but the agent will not forget any of c's past.

