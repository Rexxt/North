local LanguageContext = require "north"

local interpreter = LanguageContext()

while true do
    if #interpreter.stack > 0 then
        io.write("(" .. tostring(interpreter.stack[#interpreter.stack]) .. ") " .. "North -> ")
    else
        io.write("North -> ")
    end
    
    local input = io.read()

    local status, err = interpreter:interpret('stdin', input)
    if not status then
        -- print message like so
        --[[
    North runtime error ({error type}) at line {line}, word {word}:
        {line_str}
    {error message}
        ]]
        print("North runtime error (" .. err.error.type .. ") at line " .. err.line .. ", word " .. err.word .. ":")
        print("    " .. err.line_str)
        print(err.error.message)
    end

    local stack_representation = "["
    for i, v in ipairs(interpreter.stack) do
        if i == #interpreter.stack then
            stack_representation = stack_representation .. tostring(v)
        else
            stack_representation = stack_representation .. tostring(v) .. ", "
        end
    end
    stack_representation = stack_representation .. "]"
    print("=> " .. stack_representation)
end