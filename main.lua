local LanguageContext = require "north"

local interpreter = LanguageContext()

interpreter:interpret('stdin', 'int let x')

table.foreach(interpreter.variables, print)
