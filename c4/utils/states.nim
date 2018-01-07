type
  State* = object of RootObj

# method switch*(self: ref State, to: ref State): ref State {.base, inline.} =
#   ## By default, calling old_state.switch(new_state) does nothing and doesn't change the state.
#   ## User should create his own methods to allow switching between states.
#   result = fr

method switch*(self: ref State, to: ref State) {.base, inline.} = discard
## By default, calling old_state.switch(new_state) does nothing and doesn't change the state.
## User should create his own methods to allow switching between states.
