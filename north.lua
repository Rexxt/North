--[[ 22C - C, Forth and a bunch of other programming languages crossed into one.
The goal is to write a language similar to Forth, but with "low-level" features like C

Example program:
    int NameOfSource:
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
        y "22C" set
        y " is awesome!" , (*Concatenates "22C" and " is awesome!" and pushes to stack*)
        . (*Prints "22C is awesome!" to the console*)

        0 (*Here we return 0 by pushing it to the stack*)
    ;;
]]

local function split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

local function deep(t)
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
                table.insert(self.stack, self.stack[-1])
            end
        }
        self.stack = {}
    end,
    __call = function(self, ...)
        local obj = deep(self)
        obj:__new__(...)
        return obj
    end,
    interpret = function(self, source, code)
        code = string.gsub(code, "    ", "")
        
        local lines = split(code, "\n")
        local idx_line = 1
        
        while idx_line <= #lines do
            local line = lines[idx_line]
            
            local words = split(line, " ")
            local idx_word = 1
            
            while idx_word <= #words do
                local word = words[idx_word]
                
                -- interpretation goes here
            end
                        
            idx_line = idx_line + 1
        end
    end
}

setmetatable(LanguageContext, LanguageContext)

return LanguageContext
