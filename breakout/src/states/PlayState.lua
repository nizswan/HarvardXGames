--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level
    self.ballCount = 1
    self.powerups = {}
    self.extraBalls = {}
    self.mainBallOutOfBounds = false
    self.mainBallSkin = self.ball.skin

    self.recoverPoints = params.recoverPoints
    self.paddleIncreasePoints = 5000
    self.lastPaddleIncrease = self.score

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.score >= self.lastPaddleIncrease + self.paddleIncreasePoints then
        self.lastPaddleIncrease = self.score
        self.paddle.size = self.paddle.size + 1
    end
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    self.ball:update(dt)
    for i, balli in pairs(self.extraBalls) do
        balli:update(dt)
        if balli:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            balli.y = self.paddle.y - 8
            balli.dy = -balli.dy
    
            --
            -- tweak angle of bounce based on where it hits the paddle
            --
    
            -- if we hit the paddle on its left side while moving left...
            if balli.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                balli.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - balli.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif balli.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                balli.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - balli.x))
            end
    
            gSounds['paddle-hit']:play()
        end
    end

    if self.ball:collides(self.paddle) then
        -- raise ball above paddle in case it goes below it, then reverse dy
        self.ball.y = self.paddle.y - 8
        self.ball.dy = -self.ball.dy

        --
        -- tweak angle of bounce based on where it hits the paddle
        --

        -- if we hit the paddle on its left side while moving left...
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        
        -- else if we hit the paddle on its right side while moving right...
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        gSounds['paddle-hit']:play()
    end

    for i, powerup in pairs(self.powerups) do
        powerup:update(dt)
        if powerup:collides(self.paddle) then
            if powerup.powerupchoice == 1 then
                table.insert(self.extraBalls, Ball())
                table.insert(self.extraBalls, Ball())
                local newBallCount = #self.extraBalls
                self.extraBalls[newBallCount - 1].x = self.paddle.x + (self.paddle.width / 2)
                self.extraBalls[newBallCount - 1].y = self.paddle.y - 4
                self.extraBalls[newBallCount - 1].skin = self.mainBallSkin
                self.extraBalls[newBallCount - 1].dx = math.random(-200, 200)
                self.extraBalls[newBallCount - 1].dy = math.random(-50, -60)
                --ball.dx = math.random(-200, 200)
                --self.ball.dy = math.random(-50, -60)
                self.extraBalls[newBallCount].dx = math.random(-200, 200)
                self.extraBalls[newBallCount].dy = math.random(-50, -60)
                self.extraBalls[newBallCount].x = self.paddle.x + (self.paddle.width / 2)
                self.extraBalls[newBallCount].y = self.paddle.y - 4
                self.extraBalls[newBallCount].skin = self.mainBallSkin
                self.ballCount = self.ballCount + 2
                
            else
                if self.ball.keyUnlocked == false and self.mainBallOutOfBounds == false then
                    self.ball.keyUnlocked = true
                else
                    local foundNextUnlock = false
                    for j, ballj in pairs(self.extraBalls) do
                        if ballj.keyUnlocked == false and foundNextUnlock == false then
                            ballj.keyUnlocked = true
                            foundNextUnlock = true
                        end
                    end
                end

            end
            table.remove(self.powerups, i)
        end
    end


    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        -- only check collision if we're in play
        for p, ballp in pairs(self.extraBalls) do
            if brick.inPlay and ballp:collides(brick) then

                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)
    
                -- trigger the brick's hit function, which removes it from play
                brick:hit()
                if ballp.keyUnlocked == true and brick.locked == true then
                    brick.inPlay = false
                    self.score = self.score + 750
                end
                
                local releasePowerUp = 1
                if releasePowerUp == 1 then
                    
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    table.insert(self.powerups, Powerup(brick.x, brick.y));
                    
                    
                end
    
                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)
    
                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)
    
                    -- play recover sound effect
                    gSounds['recover']:play()
                end
    
                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()
    
                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball,
                        recoverPoints = self.recoverPoints
                    })
                end
    
                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --
    
                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ballp.x + 2 < brick.x and ballp.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ballp.dx = -ballp.dx
                    ballp.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ballp.x + 6 > brick.x + brick.width and ballp.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ballp.dx = -ballp.dx
                    ballp.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ballp.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ballp.dy = -ballp.dy
                    ballp.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ballp.dy = -ballp.dy
                    ballp.y = brick.y + 16
                end
    
                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ballp.dy) < 150 then
                    ballp.dy = ballp.dy * 1.02
                end
    
                -- only allow colliding with one brick, for corners
                break
            end
        end
        if brick.inPlay and self.ball:collides(brick) then

            -- add to score
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            -- trigger the brick's hit function, which removes it from play
            brick:hit()
            if self.ball.keyUnlocked == true and brick.locked == true then
                brick.inPlay = false
                self.score = self.score + 750
            end
            local releasePowerUp = 1
            if releasePowerUp == 1 then
                table.insert(self.powerups, Powerup(brick.x, brick.y))
            end

            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then
                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)

                -- multiply recover points by 2
                self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    ball = self.ball,
                    recoverPoints = self.recoverPoints,
                    lastPaddleIncrease = self.lastPaddleIncrease
                })
            end

            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif self.ball.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(self.ball.dy) < 150 then
                self.ball.dy = self.ball.dy * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for m, ballm in pairs(self.extraBalls) do
        if ballm.y >= VIRTUAL_HEIGHT then
            if self.ballCount > 1 then
                self.ballCount = self.ballCount - 1
                table.remove(self.extraBalls, m)
            else 
                self.extraBalls = {}
                self.health = self.health - 1
                self.paddle.size = self.paddle.size - 1
                gSounds['hurt']:play()
    
                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
        end
    end
    if self.ball.y >= VIRTUAL_HEIGHT and self.mainBallOutOfBounds == false then
        self.mainBallOutOfBounds = true
        if self.ballCount > 1 then
            self.ballCount = self.ballCount - 1
        else 
            self.extraBalls = {}
            self.health = self.health - 1
            self.paddle.size = self.paddle.size - 1
            gSounds['hurt']:play()

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints
                })
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    for k, ballk in pairs(self.extraBalls) do
        ballk:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for l, powerup in pairs(self.powerups) do
        powerup:render()
    end

    self.paddle:render()
    self.ball:render()

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end