--[[
  Usage:
  States are only created as needed, to save memory, reduce clean-up bugs and increase speed
  due to garbage collection taking longer with more data in memory.
  States are added with a string identifier and an intialisation function.
  It is expected that the init function, when called, will return a table with
  render, update, enter and exit methods.

  Example:
  GameStateMachine = StateMachine {
      ['MainMenu'] = function()
        return MainMenu()
      end,
      ['InnerGame'] = function()
        return InnerGame()
      end,
      ['GameOver'] = function()
        return GameOver()
      end,
  }
  GameStateMachine:change("MainMenu")

  Arguments passed into the Change function after the state name
  will be forwarded to the Enter function of the state being changed too.
  State identifiers should have the same name as the state table, unless there's a good
  reason not to. i.e. MainMenu creates a state using the MainMenu table. This keeps things
  straight forward.
]]

StateMachine = Class {}

--[[
  Expects a table of state tables, with each state table having
  render, update, enter and exit methods.
  Example:
  GameStateMachine = StateMachine {
      ['MainMenu'] = function()
        return MainMenu()
      end,
      ['InnerGame'] = function()
        return InnerGame()
      end,
      ['GameOver'] = function()
        return GameOver()
      end,
  }
  GameStateMachine:change("MainMenu")
]]
function StateMachine:init(states)
	self.empty = {
		render = function(_self) end,
		update = function(_self, dt) end,
		enter = function(_self, enterParams) end,
		exit = function(_self) end
	}
	self.states = states or {}
	self.current = self.empty
end

--[[
  Changing states is done by string identifier, and also includes a table of any arguments
  to be forwarded to the Enter function of the state being changed too.
  Example:
  GameStateMachine:change("InnerGame", { level = 9000 })
]]
function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName])
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter(enterParams or {})
end

--[[
  Forwarding update calls to the current state object.
]]
function StateMachine:update(dt)
	self.current:update(dt)
end

--[[
  Forwarding render calls to the current state object.
]]
function StateMachine:render()
	self.current:render()
end
