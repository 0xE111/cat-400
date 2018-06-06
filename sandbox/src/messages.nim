import c4.core.messages
import c4.utils.stringify


type
  ResetSceneMessage* = object of Message


messages.register(ResetSceneMessage)
strMethod(ResetSceneMessage)
