type
  State* = object of RootObj


method switch*(self: var ref State, newState: ref State) {.base, inline.} = discard  # TODO: use ref RootObj|void maybe?
method switch*(self: var ref State, newState: ref State, instance: ref RootObj) {.base, inline.} = discard
## A function to decide whether to switch to a new state.
## By default, calling old_state.switch(new_state) doesn't change the state.
## User should create his own methods to allow switching between states.
## Warning: calling `switch` inside `switch` may lead to stack overflow.
