
_G.love = require("love")
local misc_funcs = require("misc_funcs")

-- General variables
local default_font_size = 48
local min_font_size = 20
local default_font
local font_size = default_font_size
local scr_center= {x = (love.graphics.getWidth() / 2),  y = (love.graphics.getHeight() / 2)}
local statusText = "Click 1 to work and 2 to break"
local cmd_mode = false
local cmd_text = ""
local cursor_blink_time = {on = false, onTime = 0, delay = 0.45}

-- Sound variables
local alarmSfx
local didAlarm = false

-- Time variables
local time_display = {min = 0, sec = 0}
local time_elapsed = 0
SecElapsed = 0
SecTarget = 10 --1500
local secCurrent
local time_text = "00:00"
local isPause = true

--[[
    
    So the SecTarget is the target time for the clock,
    while the SecElapsed is what time it is in seconds.

    To get the current time just follow this formula:
        CurrentTime = SecTarget - SecElapsed

--]]

function love.load()
    love.window.maximize()
    default_font = love.graphics.newFont("default_font.ttf", font_size)
    alarmSfx = love.audio.newSource("sfx/alarm.mp3", "static")
    love.graphics.setBackgroundColor(35/255, 38/255, 52/255)
end

function love.update(dt)
    scr_center= {x = (love.graphics.getWidth() / 2),  y = (love.graphics.getHeight() / 2)}

    -- Increment time and pause method
    if (love.timer.getTime() - time_elapsed) >= 1 then
        SecElapsed = SecElapsed + 1
        time_elapsed = love.timer.getTime()
    end

    if isPause then time_elapsed = love.timer.getTime() end

    -- Calculate the time logic
    secCurrent = ((SecTarget - SecElapsed) < 0) and 0 or (SecTarget - SecElapsed)
    time_display.min = math.floor(secCurrent / 60)
    time_display.sec = math.floor(secCurrent - (time_display.min * 60))

    -- Diplay the time
    local min_display = (time_display.min >= 10) and time_display.min or "0" .. time_display.min
    local sec_display = (time_display.sec >= 10) and time_display.sec or "0" .. time_display.sec
    time_text =  min_display .. ":" .. sec_display

    -- Set the alarm off after the timer ends
    if not didAlarm and secCurrent <= 0 then
        love.audio.play(alarmSfx)
        statusText = "Timer is done"
        os.execute('notify-send -u normal "Pomodoro timer is done."')
        isPause = true
        didAlarm = true
    end

    -- Disable command after too much backspace
    if cmd_mode and cmd_text == "" then
        cmd_mode = false
        cmd_text = ""
    end
end

function love.draw()
    -- Generating the text test
    love.graphics.setFont(default_font)
    local textSizeW = default_font:getWidth(time_text)
    local textSizeH = default_font:getHeight(time_text)
    if isPause then
        -- love.graphics.setColor(1, 0, 0)
        love.graphics.setColor(231/255, 130/255, 132/255)
    else
        love.graphics.setColor(153/255, 209/255, 219/255)
    end

    love.graphics.print(time_text, scr_center.x - (textSizeW / 2), scr_center.y - (textSizeH / 2))

    -- Alarm info displaay
    local statusTextScale = 0.3
    local doneTxtPos = {
        x = scr_center.x - ((default_font:getWidth(statusText) * statusTextScale) / 2),
        y = (scr_center.y - (textSizeH / 2)) + (textSizeH+2)
    }

    if didAlarm then
        love.graphics.setColor(231/255, 130/255, 132/255)
        love.graphics.print(statusText, doneTxtPos.x,  doneTxtPos.y, 0, statusTextScale, statusTextScale)
    else
        if statusText == "Break" then
            love.graphics.setColor(140/255, 170/255, 238/255)
        else
            love.graphics.setColor(229/255, 200/255, 144/255)
        end
        love.graphics.print(statusText, doneTxtPos.x,  doneTxtPos.y, 0, statusTextScale, statusTextScale)
    end

    love.graphics.setColor(166/255, 209/255, 137/255)
    if font_size == default_font_size then
        love.graphics.print("Scroll using the mouse wheel to resize.", 20,  20, 0, 0.45, 0.45)
    end

    love.graphics.setColor(231/255, 130/255, 132/255)
    love.graphics.print(cmd_text, 20,  love.graphics.getHeight() - (textSizeH * 0.6 + 10), 0, 0.6, 0.6)
    local CmdTextSizeW = default_font:getWidth(cmd_text)
    local CmdTextSizeH = default_font:getHeight(cmd_text)
    local blinkCond = (love.timer.getTime() - cursor_blink_time.onTime > cursor_blink_time.delay)

    if cmd_mode and cursor_blink_time.on then
        love.graphics.rectangle('fill', 23 + (CmdTextSizeW * 0.6), love.graphics.getHeight() - (textSizeH * 0.6 + 8), 5, (CmdTextSizeH * 0.5))
    end

    if blinkCond then
        cursor_blink_time.on = not cursor_blink_time.on
        cursor_blink_time.onTime = love.timer.getTime()
    end
end

function love.keypressed(key)
    if key == "escape" and not cmd_mode then
        love.event.quit()
    elseif key == "escape" and cmd_mode then
        if cmd_mode then
            cmd_text = ""
            cmd_mode = false
        end
    end

    if not cmd_mode then

    if key == "1" then
        didAlarm = false
        SecElapsed = 0
        SecTarget = 1500
        statusText = "Working"
    end

    if key == "2" then
        didAlarm = false
        SecElapsed = 0
        SecTarget = 300
        statusText = "Break"
    end

    if key == "space" then
        isPause = not isPause
    end

    end

    if key == "/" then
        if not cmd_mode then
            cmd_text = "/"
            cmd_mode = true
        elseif cmd_mode then
            cmd_text = ""
            cmd_mode = false
        end
    end

    if key == "backspace" then
        local strEnd = string.len(cmd_text)
        cmd_text = string.sub(cmd_text, 1, strEnd-1)
    end

    if key == "return" then
        local cmd_list = misc_funcs.split_str(string.sub(cmd_text, 2, string.len(cmd_text)), " ")
        misc_funcs.handle_command(cmd_list)
        cmd_text = ""
        cmd_mode = false
    end
end

function love.textinput(txt)
    if cmd_mode and txt ~= '/' then
        cmd_text = cmd_text .. txt
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
