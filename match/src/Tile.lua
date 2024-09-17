--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    self.shinyOdds = math.random(1, 12)
    if self.shinyOdds == 1 then
        self.shiny = true
    else
        self.shiny = false
    end
end

function Tile:render(x, y)
    
    -- draw shadow
    if(self.shiny == false) then
        love.graphics.setColor(34, 32, 52, 255)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 2, self.y + y + 2)
    else
        love.graphics.setColor(255, 255, 100, 255)
        local altVarietyShadow = (self.color + 8)
        if altVarietyShadow > 16 then
            altVarietyShadow = altVarietyShadow - 16
        end
        love.graphics.draw(gTextures['main'], gFrames['tiles'][altVarietyShadow][self.variety],
            self.x + x + 3, self.y + y + 3)
    end

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
end