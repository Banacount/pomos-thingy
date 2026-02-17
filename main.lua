
_G.love = require("love")
local misc_funcs = require("misc_funcs")

-- General variables
local default_font_size = 48
local min_font_size = 20
local default_font
local font_size = default_font_size
local scr_center= {x = (love.graphics.getWidth() / 2),  y = (love.graphics.getHeight() / 2)}
local statusText = "Click 1 to work and 2 to break"

-- Sound variables
local alarmSfx
local didAlarm = false

-- Time variables
local time_display = {min = 0, sec = 0}
local time_elapsed = 0
local sec_elapsed = 0
local sec_target = 4 --1500
local secCurrent
local time_text = "00:00"
local isPause = true

function love.load()
    love.window.maximize()
    default_font = love.graphics.newFont("default_font.ttf", font_size)
    alarmSfx = love.audio.newSource("sfx/alarm.mp3", "static")
end

function love.update(dt)
    scr_center= {x = (love.graphics.getWidth() / 2),  y = (love.graphics.getHeight() / 2)}

    -- Increment time and pause method
    if (love.timer.getTime() - time_elapsed) >= 1 then
        sec_elapsed = sec_elapsed + 1
        time_elapsed = love.timer.getTime()
    end

    if isPause then time_elapsed = love.timer.getTime() end

    -- Calculate the time logic
    secCurrent = ((sec_target - sec_elapsed) < 0) and 0 or (sec_target - sec_elapsed)
    time_display.min = math.floor(secCurrent / 60)
    time_display.sec = math.floor(secCurrent - (time_display.min * 60))

    -- Diplay the time
    local min_display = (time_display.min >= 10) and time_display.min or "0" .. time_display.min
    local sec_display = (time_display.sec >= 10) and time_display.sec or "0" .. time_display.sec
    time_text =  min_display .. ":" .. sec_display

    if not didAlarm and secCurrent <= 0 then
        love.audio.play(alarmSfx)
        statusText = "Timer is done"
        os.execute('notify-send -u normal "Pomodoro timer is done."')
        isPause = true
        didAlarm = true
    end
end

function love.draw()
    -- Generating the text test
    love.graphics.setFont(default_font)
    local textSizeW = default_font:getWidth(time_text)
    local textSizeH = default_font:getHeight(time_text)
    if isPause then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print(time_text, scr_center.x - (textSizeW / 2), scr_center.y - (textSizeH / 2))

    -- Alarm info displaay
    local statusTextScale = 0.3
    local doneTxtPos = {
        x = scr_center.x - ((default_font:getWidth(statusText) * statusTextScale) / 2),
        y = (scr_center.y - (textSizeH / 2)) + (textSizeH+2)
    }

    if didAlarm then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(statusText, doneTxtPos.x,  doneTxtPos.y, 0, statusTextScale, statusTextScale)
    else
        if statusText == "Break" then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(0, 1, 0)
        end
        love.graphics.print(statusText, doneTxtPos.x,  doneTxtPos.y, 0, statusTextScale, statusTextScale)
    end

    if font_size == default_font_size then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Scroll using the mouse wheel to resize.", 20,  20, 0, 0.5, 0.5)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "1" then
        didAlarm = false
        sec_elapsed = 0
        sec_target = 1500
        statusText = "Working"
    end

    if key == "2" then
        didAlarm = false
        sec_elapsed = 0
        sec_target = 300
        statusText = "Break"
    end

    if key == "space" then
        isPause = not isPause
    end
end

function love.wheelmoved(x, y)
    if y > 0 and font_size < 328 then
        font_size = font_size + 5
        default_font = love.graphics.newFont("default_font.ttf", font_size)
    elseif y < 0 and font_size > min_font_size then
        font_size = font_size - 5
        default_font = love.graphics.newFont("default_font.ttf", font_size)
    end
end
