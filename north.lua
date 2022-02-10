--[[ North - C, Forth and a bunch of other programming languages crossed into one.
The goal is to write a language similar to Forth, but with "low-level" features like C and some concepts from other languages and other paradigms.

Example program:
    int main:
        "Hello, world!" . (*Here we push "Hello, world!" to the stack and then print it*)
        (*Now we will create an int variable and manipulate it*)
        int let x
        x 5 set
        x get . (*Prints "5" to the console*)
        x ++ (*Adds 1 to x*)
        x get . (*Prints "6" to the console*)
        x -- (*Subtracts 1 from x*)
        x get . (*Prints "5" to the console*)

        (*We created a variable and manipulated it, but we don't need it anymore, so we'll clear it*)
        x clear

        (*However, this does not free space in the dictionary, so we need to free it ourselves*)
        cleanup

        (*Now we can create a new variable*)
        str let y
        y "North" set
        y " is awesome!" , (*Concatenates "North" and " is awesome!" and pushes to stack*)
        . (*Prints "North is awesome!" to the console*)

        0 (*Here we return 0 by pushing it to the stack*)
    ;;

    main (*Here we execute the main function we created above*)
]]

local function split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

local function deep(t) -- deep copy a table
    local new_table = {}
    
    for k, v in pairs(t) do
        if type(v) == "table" then
            new_table[k] = deep(v)
        else
            new_table[k] = v
        end
    end
    
    return new_table
end

local Variable = {
    -- Variable class
    -- Holds data and a type

    __new__ = function(self, vartype, name, value)
        self.vartype = vartype
        self.name = name
        self.value = value
    end,
    
    __call = function(self, ...) -- instanciation
        local obj = deep(self)
        obj.super = self
        obj:__new__(...)
        return obj
    end
}

setmetatable(Variable, Variable)

local LanguageContext = {
    __new__ = function(self)
        self.variables = {}
        self.functions = {
            dup = function(self)
                table.insert(self.stack, self.stack[#self.stack])
                return true, nil
            end,
            drop = function(self)
                table.remove(self.stack)
                return true, nil
            end,
            exit = function(self)
                if #self.stack > 0 then
                    os.exit(self.get_raw_value(table.remove(self.stack)))
                else
                    os.exit(0)
                end
            end,
            ["+"] = function(self)
                -- check if there are at least 2 elements on the stack
                if #self.stack < 2 then
                    return false, {type = "StackUnderflowError", message = "Not enough elements on the stack (expected 2)."}
                end
                -- pop two values from stack
                local b, a = table.remove(self.stack), table.remove(self.stack)
                if a == nil or b == nil then
                    return false, {type = "NullOperationError", message = "Attempted to perform operation on null."}
                end
                -- add them
                table.insert(self.stack, a + b)
                -- register stack change
                self.stack_changes = self.stack_changes + 1
                return true, nil
            end,
            ["-"] = function(self)
                -- check if there are at least 2 elements on the stack
                if #self.stack < 2 then
                    return false, {type = "StackUnderflowError", message = "Not enough elements on the stack (expected 2)."}
                end
                -- pop two values from stack
                local b, a = table.remove(self.stack), table.remove(self.stack)
                if a == nil or b == nil then
                    return false, {type = "NullOperationError", message = "Attempted to perform operation on null."}
                end
                -- subtract them
                table.insert(self.stack, a - b)
                -- register stack change
                self.stack_changes = self.stack_changes + 1
                return true, nil
            end,
            ["*"] = function(self)
                -- check if there are at least 2 elements on the stack
                if #self.stack < 2 then
                    return false, {type = "StackUnderflowError", message = "Not enough elements on the stack (expected 2)."}
                end
                -- pop two values from stack
                local b, a = table.remove(self.stack), table.remove(self.stack)
                if a == nil or b == nil then
                    return false, {type = "NullOperationError", message = "Attempted to perform operation on null."}
                end
                -- multiply them
                table.insert(self.stack, a * b)
                -- register stack change
                self.stack_changes = self.stack_changes + 1
                return true, nil
            end,
            ["/"] = function(self)
                -- check if there are at least 2 elements on the stack
                if #self.stack < 2 then
                    return false, {type = "StackUnderflowError", message = "Not enough elements on the stack (expected 2)."}
                end
                -- pop two values from stack
                local b, a = table.remove(self.stack), table.remove(self.stack)
                if a == nil or b == nil then
                    return false, {type = "NullOperationError", message = "Attempted to perform operation on null."}
                end
                -- make sure we're not dividing by zero
                if b == 0 then
                    return false, {type = "DivisionByZeroError", message = "Attempted to divide by zero."}
                end
                -- divide them
                table.insert(self.stack, a / b)
                -- register stack change
                self.stack_changes = self.stack_changes + 1
                return true, nil
            end,
            print = function(self)
                print(table.remove(self.stack))
                return true, nil
            end
        }
        self.stack = {}
        self.stack_changes = 0
    end,
    __call = function(self, ...)
        local obj = deep(self)
        obj.super = self
        obj:__new__(...)
        return obj
    end,

    get_raw_value = function(str)
        -- trying to get number
        local number = tonumber(str)
        if number then
            return number
        end
        -- trying to get string
        local s = string.match(str, '^"(.*)"$')
        if s then
            return string.sub(s, 1, -2)
        end
        -- trying to get boolean
        if str == 'true' then
            return true
        elseif str == 'false' then
            return false
        end
        -- trying to get empty array
        if str == '[]' then
            return {}
        end
        -- trying to get empty table
        if str == '#()' then
            return {}
        end
        -- error
        return nil, 'Could not resolve value ' .. str .. '.'
    end,
    interpret = function(self, source, code)
        code = string.gsub(code, "    ", "")

        local previous_stack = deep(self.stack)
        
        local lines = split(code, "\n")
        local idx_line = 1
        
        while idx_line <= #lines do
            local line = lines[idx_line]
            
            local words = split(line, " ")
            local idx_word = 1
            
            while idx_word <= #words do
                local word = words[idx_word]
                
                -- interpretation goes here
                -- print("Reading word " .. word)

                -- if word is not empty
                if word ~= "" then
                    -- try to see if it is a function
                    local func = self.functions[word]
                    if func then
                        -- if type is function, call it
                        if type(func) == 'function' then
                            local status, err = func(self)
                            if not status then
                                return false, {
                                    line = idx_line,
                                    word = idx_word,
                                    line_str = line,
                                    error = {
                                        type = err.type,
                                        message = err.message
                                    }
                                }
                            end
                        end
                    else
                        -- try to push value to stack
                        local value, err = self.get_raw_value(word)
                        if value then
                            table.insert(self.stack, value)
                            self.stack_changes = self.stack_changes + 1
                        else
                            -- something went wrong
                            -- return error
                            return false, {
                                line = idx_line,
                                word = idx_word,
                                line_str = line,
                                error = {
                                    type = "ResolutionError",
                                    message = err
                                }
                            }
                        end
                    end
                end

                idx_word = idx_word + 1
            end
                        
            idx_line = idx_line + 1
        end

        return true, nil
    end
}

setmetatable(LanguageContext, LanguageContext)

return LanguageContext
