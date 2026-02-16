
_G.love = require("love")
local misc_funcs = require("misc_funcs")

-- General variables
local default_font_size = 48
local min_font_size = 20
local default_font
local font_size = default_font_size

local teststring = "00:00"
local scr_center= {x = (love.graphics.getWidth() / 2),  y = (love.graphics.getHeight() / 2)}

function love.load()
    love.window.maximize()
    default_font = love.graphics.newFont("default_font.ttf", font_size)
end

function love.update(dt)
    scr_center= {x = (love.graphics.getWidth() / 2),  y = (love.graphics.getHeight() / 2)}
end

function love.draw()
    -- Generating the text test
    love.graphics.setFont(default_font)
    love.graphics.setColor(0, 1, 0)
    local textSizeW = default_font:getWidth(teststring)
    local textSizeH = default_font:getHeight(teststring)
    love.graphics.print(teststring, scr_center.x - (textSizeW / 2), scr_center.y - (textSizeH / 2))
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        font_size = font_size + 5
        default_font = love.graphics.newFont("default_font.ttf", font_size)
    elseif y < 0 and font_size > min_font_size then
        font_size = font_size - 5
        default_font = love.graphics.newFont("default_font.ttf", font_size)
    end
end
