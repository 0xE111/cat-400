type
  State* = object of RootObj
  None* = object of State

method switch*(fr: ref State, to: ref State): ref State {.base, inline.} =  # TODO: rename "fr" to "from"
  ## By default, calling old_state.switch(new_state) does nothing and doesn't change the state.
  ## User should create his own methods to allow switching between states.
  result = fr
