Powerup = Class{}

function Powerup:init(x, y)
    self.powerupchoice = math.random(1, 2)
    self.dx = 0
    self.dy = 40
    self.x = x
    self.y  = y
    self.width = 16
    self.height = 16
end

function Powerup:update(dt)
    self.y = self.y + dt * self.dy
    self.x = self.x + dt * self.dx

end

function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.powerupchoice], self.x, self.y)
end