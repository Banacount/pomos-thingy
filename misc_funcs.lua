local misc = {}

misc.split_str = function (str, sep)
    local fields = {}
    str = str .. sep

    for cap in str:gmatch("(.-)" .. sep) do
        table.insert(fields, cap)
    end

    return fields
end

misc.handle_command = function (str_list)
    -- This the time commands
    -- The number 60 in this code is impying the seconds per minute
    if str_list[1] == "sec" then
        if #str_list >= 2 then
            local param2 = tonumber(str_list[2]) or 0
            local int_t, dec_t = math.modf((SecTarget-SecElapsed) / 60)
            local min, max = 0, 59

            if param2 > min and param2 <= max then SecTarget = (int_t * 60)+param2
            elseif param2 >= max then SecTarget = (int_t * 60)+max
            else SecTarget = (int_t * 60)+1 end

            SecElapsed = 0
        end
    end
    if str_list[1] == "min" then
        if #str_list >= 2 then
            local param2 = tonumber(str_list[2]) or 0
            local int_t, dec_t = math.modf((SecTarget-SecElapsed) / 60)
            local min, max = 0, 200

            if param2 > min and param2 <= max then SecTarget = (dec_t * 60)+(param2 * 60)
            elseif param2 >= max then SecTarget = (dec_t * 60)+(max * 60)
            else SecTarget = (dec_t * 60)+60 end

            SecElapsed = 0
        end
    end
end

return misc
