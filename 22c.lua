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

local Variable = {
    __new__ = function(self, vartype, name, value)
        self.vartype = vartype
        self.name = name
    end
}
