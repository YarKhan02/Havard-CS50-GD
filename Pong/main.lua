push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

EASY_MULTIPLIER = 0.6

-- CALLED JUST ONCE AT THE BEGINNING OF THE GAME TO SET UP ENVIRONMENT AND PREPARE THE WORLD
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong') -- GAME TITLE

    math.randomseed(os.time()) -- TO ALWAYS CALL A RANDOM NUMBER

    -- INITIALIZING RETRO TEXT FONT
    smallFont = love.graphics.newFont('font.ttf', 8) 
    scoreFont = love.graphics.newFont('font.ttf', 32) 
    largeFont = love.graphics.newFont('font.ttf', 16) 
    love.graphics.setFont(smallFont) -- SET LOVE2D'S ACTIVE FONT TO SMALL FONT

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- INITIALIZING VIRTUAL RESOLUTION WHICH WILL BE RENDERED WITHIN ACTUAL WINDOW NO MATTER ITS DIMENSION
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    -- INITIALIZING SCORE VARIABLE
    player1Score = 0
    player2Score = 0

    -- INITIALIZE PLAYER PADDLES; MAKE THEM GLOBAL SO THAT THEY CAN BE DETECTED BY OTHER FUNCTIONS AND MODULES
    player1 = Paddle(5, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    servingPlayer = 1

    winningPlayer = 0

    -- PLACE A BALL IN THE MIDDLE OF THE SCREEN
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    
    -- IT IS USED TO TRANSITION BETWEEN DIFFERENT PARTS OF THE GAME
    gameState = 'start'
end

-- CALLED WHENEVER THE DIMENSION OF THE WINDOW IS CHANGED || EXAMPLE: DRAGGING ITS BOTTOM CORNER 
function love.resize(w, h)
    push:resize(w, h)
end

-- CALLED EVERY FRAME
function love.update(dt) 
    if gameState == 'serve' then

        ball.dy = math.random(-50, 50)

        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end

        -- ADDING AI PLAYERS
        if servingPlayer == 1 and player1.typePlayer == 'ai' then
            gameState = 'play'
        elseif servingPlayer == 2 and player2.typePlayer == 'ai' then
            gameState = 'play'
        end

    elseif gameState == 'play' then
        
        -- DETECT BALL COLLISION WITH PADDLE AND REVERSING THE BALL DIRECTION 
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.05
            ball.x = player1.x + 5

            -- RANDOMIZING BALL DIRECTION 
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150) 
            end

            sounds['paddle_hit']:play()
        end

        -- DETECT BALL COLLISION WITH PADDLE AND REVERSING THE BALL DIRECTION
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.05
            ball.x = player2.x - 4

            -- RANDOMIZING BALL DIRECTION
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150) 
            end

            sounds['paddle_hit']:play()
        end

        -- DETECT UPPER AND LOWER SIDE COLLISION AND REVERSE IF COLLIDES
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 TO ACCOUNT FOR BALL SIZE
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- IF WE REACH LEFT AND RIGHT EDGE OF THE SCREEN, RESET GAME AND UPDATE THE SCORE
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    -- PLAYER 1 MOVEMENT
    if player1.typePlayer == 'human' then
        if love.keyboard.isDown('w') then
            player1.action = 'move_up' -- MOVE UPWARDS
        elseif love.keyboard.isDown('s') then
            player1.action = 'move_down' -- MOVE DOWNWARDS
        else
            player1.action = 'wait'
        end
    else
        if player1.ai == 'random' then
            player1:aiRandom()
        elseif player1.ai == 'bot' then
            player1:aiBot(ball.y)
        end
    end

    -- PLYER 2 MOVEMENT
    if player2.typePlayer == 'human' then
        if love.keyboard.isDown('up') then
            player2.action = 'move_up' -- MOVE UPWARDS
        elseif love.keyboard.isDown('down') then
            player2.action = 'move_down' -- MOVE DOWNWARDS
        else
            player2.action = 'wait'
        end
    else
        if player2.ai == 'random' then
            player2:aiRandom()
        elseif player2.ai == 'bot' then
            player2:aiBot(ball.y)
        end
    end

    --AI PADDLES
    if player1.ai == 'bot' then
        if player1.action == 'move_up' then
            player1.dy = -PADDLE_SPEED * EASY_MULTIPLIER
        elseif player1.action == 'move_down' then
            player1.dy = PADDLE_SPEED * EASY_MULTIPLIER
        else
            player1.dy = 0
        end
    else
        if player1.action == 'move_up' then
            player1.dy = -PADDLE_SPEED
        elseif player1.action == 'move_down' then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end
    end

    if player2.ai == 'bot' then
        if player2.action == 'move_up' then
            player2.dy = -PADDLE_SPEED * EASY_MULTIPLIER
        elseif player2.action == 'move_down' then
            player2.dy = PADDLE_SPEED * EASY_MULTIPLIER
        else
            player2.dy = 0
        end
    else
        if player2.action == 'move_up' then
            player2.dy = -PADDLE_SPEED
        elseif player2.action == 'move_down' then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

-- A CALLBACK THAT PROCESS KEYSTROKES AS THEY HAPPEN
function love.keypressed(key)
    if key == 'escape' then   -- TO TERMINATE APPLICATION
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'select'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'select'

            ball:reset()

            -- RESET SCORE TO 0
            player1Score = 0
            player2Score = 0

            -- DECIDE SERVING PLAYER AS THE OPPOSITE WHO WON
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end

     -- CHOOSING BASED ON STATES
    elseif key == '0' then
        if gameState == 'select' then
            player1.typePlayer = 'ai'
            player2.typePlayer = 'ai'
            gameState = 'serve'
        end

    elseif key == '1' then
        if gameState == 'select' then
            player1.typePlayer = 'human'
            player2.typePlayer = 'ai'
            gameState = 'serve'
        end

    elseif key == '2' then
        if gameState == 'select' then
            player1.typePlayer = 'human'
            player2.typePlayer = 'human'
            gameState = 'serve'
        end
    end
end

-- CALLED EACH FRAME AFTER UPDATE
function love.draw()
    push:start()

    love.graphics.clear(0, 0, 0, 255)

    -- DISPLAY SCORE
    displayscore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Start State!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter To Begin!',0, 20, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'select' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press number for: 0- BOTS, 1- SINGLE PLAYER, or 2- MULTIPLIER', 0, 20, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player '.. tostring(servingPlayer) .. " 's Serve" , 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter To Serve', 0, 20, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'play' then

    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter To Restrat!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- RENDER PADDLES, NOW USING THEIR CLASS'S RENDER METHOD
    player1:render()
    player2:render()

    -- RENDER BALL USING IT CLASS'S RENDER METHOD
    ball:render()

    -- DISPLAY-FPS
    displayFPS()

    push:finish()
end

-- RENDER THE CURRENT FPS
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

-- RENDER THE CURRENT SCORE
function displayscore()
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(tonumber(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(255, 255, 255, 255)
end