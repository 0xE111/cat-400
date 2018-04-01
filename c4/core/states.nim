from logging import debug
from typetraits import name
export name

type
  State* = object {.inheritable.}


method onLeave*(self: ref State) {.base, inline.} = discard
method onEnter*(self: ref State) {.base, inline.} = discard

template switch*(self, newState: ref State) =
  logging.debug "Switching " & self[].type.name & " to " & newState[].type.name
  self.onLeave()
  self = newState
  newState.onEnter()
  

# method switch*(self: var ref State, newState: ref State) {.base, inline.} = discard  # TODO: use ref RootObj|void maybe?
# method switch*(self: var ref State, newState: ref State, instance: ref object) {.base, inline.} = discard
# ## A function to decide whether to switch to a new state.
# ## By default, calling old_state.switch(new_state) doesn't change the state.
# ## User should create his own methods to allow switching between states.
# ## Warning: calling `switch` inside `switch` may lead to stack overflow.

# method update*(self: var ref State, instance: ref object) {.base, inline.} = discard
