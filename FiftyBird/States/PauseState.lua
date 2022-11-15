PauseState = Class{__includes = BaseState}

function PauseState:init()
    self.image = love.graphics.newImage('pause.png')
    self.width = self.image: getWidth()
    self.height = self.image: getHeight()
end

function PauseState:update(dt)
    if love.keyboard.wasPressed('p') or love.keyboard.wasPressed('P') then
        sounds['pause']:setLooping(false)
        sounds['music']:play()
        gStateMachine:stateUnPause('play')
    end
end

function PauseState:render()
    sounds['pause']:setLooping(true)
    sounds['pause']:play()

    love.graphics.setFont(flappyFont)
    love.graphics.printf('The game is Paused!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.draw(self.image, VIRTUAL_WIDTH / 2 - (self.width / 2), VIRTUAL_HEIGHT / 2 - (self.height / 2))

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press P To Resume!', 0, 200, VIRTUAL_WIDTH, 'center')
end