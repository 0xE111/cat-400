import c4/messages
import c4/utils/stringify


type
  # This message will reset physics system to initial state, so that we can play again
  ResetSceneMessage* = object of Message


# Always ``register`` Message subtypes. If not registered, network system won't have a knowledge on how to serialize the message, which will lead to sending pure ``Message`` instead of your subtype.
messages.register(ResetSceneMessage)
