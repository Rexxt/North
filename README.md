# North
Hear me out: what if we crossed C, Forth and a bunch of other programming languages into one?

cursed af programming language

i mean really, look at this
```north
int main:
  (*initial stack element is command line args when you run the program from the terminal*)
  str[] let args
  args rot set (*put args pointer on stack, swap its position with the command line arguments and affect arguments to args*)
  
  (*note: ";" skips the block, for better readability of the code.*)
  args get listlen ; 0 ; == ; ifTrue
    "Hey!" . (*put "Hey!" on stack and print it)
  ;; else
    "Hey " args get 0 idx , "!" ,.
    (*that's a complicated statement, let me break it down:
      "Hey " <- put that string on the stack, the space is intentional
      args get <- put the argument array on the the stack
      0 idx <- get the first element of the array (arrays start at 0)
      , <- concatenate the two strings at the top of the stack
      "!" <- put that string on the stack
      ,. <- concatenate and print (equivalent to {, .} but shaves off a character)
    *)
  ;;
  
  0 (*return value is an int*)
;;

(*now admitting we wrote that in the command line interpreter*)
[ ] main . (*prints "Hey!" and 0)
[ "North" ] main . (*prints "Hey North!" and 0*)
```
