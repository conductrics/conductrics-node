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


Please see the [full documentation](https://console.conductrics.com/docs/owner_code/api-reference), for more information on everything you can do with the Conductrics API.
