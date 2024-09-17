PauseState = Class{__includes = BaseState}

function PauseState:init()
    self.pauseImage = love.graphics.newImage('pause.png') -- Load once
end

function PauseState:enter(params)
    self.previousDt = params.dt -- Passed from PlayState potentially
end

function PauseState:update(dt)
    if love.keyboard.wasPressed('p') then
        gStateMachine:change('play', {dt = self.previousDt}) -- Pass dt back if needed
    end
end

function PauseState:render()
    love.graphics.draw(self.pauseImage, VIRTUAL_WIDTH / 2 - self.pauseImage:getWidth() / 2, VIRTUAL_HEIGHT / 2 - self.pauseImage:getHeight() / 2)
end