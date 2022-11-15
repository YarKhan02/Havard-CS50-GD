StateMachine = Class{}

function StateMachine:init(states)
    self.empty = {
        render = function() end,
        update = function() end,
        enter = function() end,
        exit = function() end
    }

    self.states = states or {}
    self.current = self.empty
    self.pauseState = self.empty
end

function StateMachine:change(stateName, enterParams)
    assert(self.states[stateName])

    self.current:exit()
    self.current = self.states[stateName]()
    self.current:enter(enterParams)
end

function StateMachine:statePause(stateName, enterPrams)
    assert(self.states[stateName])

    self.pauseState = self.current
    self.current = self.states[stateName]()
    self.current:enter(enterPrams)
end

function StateMachine:stateUnPause(stateName, enterParams)
    self.current = self.pauseState
    self.pauseState = self.empty
    self.current:enter(enterParams)
end

function StateMachine:update(dt)
    self.current:update(dt)
end

function StateMachine:render()
    self.current:render()
end