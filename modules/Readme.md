#Developer readme

## Hook
 - jhud.hook("CLASS", "FUNCTION", yourfunction, hooktype or jhud.hook.PREHOOK) |
 Valid hooktypes are:
   - PREHOOK | Arguments: The original function arguments (Including self) |
   executes callback before the original function is called. Return
   true to disable the execution of the original function, or return a table with
   indicies that represent the index of the arguements witch will overwrite the
   arguements that are passed to the next function. This is an example taken
   from modules/chat.lua

```Lua
this.chatEmotes = function(cg, name, message, ...)
	return{
		[2] = jhud.chat:sterileEmotes(name),
		[3] = jhud.chat:sterileEmotes(message)
	}
end
```
   - POSTHOOK | args: the original arguemnts to the function(including self) and
   a table containing the results of the original function. | Executes directly
   after the original function is called. This will not execute if the original
   function is cancelled. Return a table with indicies that represent the return
   values to overwrite what is actually returned by the function. This is an
   example
```Lua
jhud.hook("FunctionClass", "func", function(forward, rets)
	if rets[1] > 5 and forward[3] == 3 then
		return {
			[1] = 3 --Make the original function now return '3'
		}
	end
end, jhud.hook.POSTHOOK)
```
	- OVERWRITE | args: The original function arguments including self | Directly
	overwrite a function. This will disable all hooks. Only use this if you both
	know what you're doing, and know what the risks are. No example included.

## Net
	TODO

## Bind
	TODO
