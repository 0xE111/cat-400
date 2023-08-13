import c4/messages


type
  CreateEntityMessage* = object of Message
    x*: float
    y*: float
    z*: float

  RotateEntityMessage* = object of Message
    angle*: float
