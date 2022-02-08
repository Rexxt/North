local LanguageContext = require "22c"

local interpreter = LanguageContext()

interpreter:interpret('stdin', 'int let x')

table.foreach(interpreter.variables, print)
