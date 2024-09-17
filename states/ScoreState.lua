--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:init()
    -- Load the images once when the state is initialized
    self.goldImage = love.graphics.newImage('gold.png')
    self.silverImage = love.graphics.newImage('silver.png')
    self.bronzeImage = love.graphics.newImage('bronze.png')
end

function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    
    --love.graphics.printf('Oof! You lost!' , 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(flappyFont)
    if self.score > 14 then
        love.graphics.printf('Congratulations on Gold (15+)' , 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(self.goldImage, (VIRTUAL_WIDTH / 2) - (0.15 * 400 * 0.5), VIRTUAL_HEIGHT * 0.5 - 25, 0, 0.15, 0.15);
        --the reason for 0.5 is to center it, 0.15 si the scale we are shrinking the image by, and the image is a 400x400 px image
    elseif self.score > 9 then
        love.graphics.printf(('Congratulation on Silver (10+)') , 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(self.silverImage, (VIRTUAL_WIDTH /2) - (0.15 * 400 * 0.5), VIRTUAL_HEIGHT * 0.5 - 25, 0, 0.15, 0.15);
        --the reason for 0.5 is to center it, 0.15 si the scale we are shrinking the image by, and the image is a 400x400 px image
    elseif self.score > 4 then
        love.graphics.printf('Congratulation on Bronze (5+)' , 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(self.bronzeImage, (VIRTUAL_WIDTH / 2) - (0.15 * 400 * 0.5), VIRTUAL_HEIGHT * 0.5 - 25, 0, 0.15, 0.15);
        --the reason for 0.5 is to center it, 0.15 si the scale we are shrinking the image by, and the image is a 400x400 px image
    else
        love.graphics.printf('Oof! You lost!' , 0, 64, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.printf('Press Enter to Play Again!', 0, 200, VIRTUAL_WIDTH, 'center')
end