from c4.server import State, Loading

type
  Intro* = object of State

method switch*(fr: ref State, to: ref Loading) =
  echo("Custom switch")
