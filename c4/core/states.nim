from logging import debug

from typetraits import name
export name

type
  State* = object {.inheritable.}

# method onLeave*[T](self: ref State, instance: ref T) {.base, inline.} = discard
# method onEnter*[T](self: ref State, instance: ref T) {.base, inline.} = discard

method onEnter*(self: ref State) {.base, inline.} = discard
method onLeave*(self: ref State) {.base, inline.} = discard


template switch*(self, newState: ref State) =
  logging.debug "Switching " & self[].type.name & " to " & newState[].type.name
  
  self.onLeave()
  self = newState
  newState.onEnter()
