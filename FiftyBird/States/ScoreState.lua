ScoreState = Class{__includes = BaseState}

function ScoreState:init()
    self.gold = love.graphics.newImage('gold.png')
    self.width1 = self.gold: getWidth()
    self.height1 = self.gold: getHeight()

    self.silver = love.graphics.newImage('silver.png')
    self.width2 = self.silver: getWidth()
    self.height2 = self.silver: getHeight()

    self.bronze = love.graphics.newImage('bronze.png')
    self.width3 = self.bronze: getWidth()
    self.height3 = self.bronze: getHeight()
end

function ScoreState:enter(params)
    self.score = params.score

    self.medal = nil
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 90, VIRTUAL_WIDTH, 'center')

    if tonumber(self.score) > 6 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('You Recieved Gold Trophy!', 0, 54, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(self.gold, VIRTUAL_WIDTH / 2 - (self.width1 / 2), VIRTUAL_HEIGHT / 2 - (self.height1 / 2))
    elseif tonumber(self.score) > 3 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('You Recieved Silver Trophy!', 0, 54, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(self.silver, VIRTUAL_WIDTH / 2 - (self.width2 / 2), VIRTUAL_HEIGHT / 2 - (self.height2 / 2))
    elseif tonumber(self.score) > 0 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('You Recieved Bronze Trophy!', 0, 54, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(self.bronze, VIRTUAL_WIDTH / 2 - (self.width3 / 2), VIRTUAL_HEIGHT / 2 - (self.height3 / 2))
    end

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press enter to play again!', 0, 190, VIRTUAL_WIDTH, 'center')
end