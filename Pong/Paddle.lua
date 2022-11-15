Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0

    self.ai = 'bot'
	self.typePlayer = 'human'
	self.action = 'wait'
	self.randomState = 'move_up'
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Paddle:aiRandom()
    if self.randomstate == 'move_up' then
        self.action = 'move_up'
    else
        self.action = 'move_down'
    end

    if self.y == 0 then
        self.randomState = 'move_down'
    elseif self.y == VIRTUAL_HEIGHT - self.height then
        self.randomState = 'move_up'
    end
end

-- AI WILL FOLLOW THE BALL MOVEMENT
function Paddle:aiBot(bally)
    if bally < self.y + 1 then
        self.action = 'move_up'
    elseif  bally > self.y + 3 then
        self.action = 'move_down'
    else
        self.action = 'wait'
    end
end