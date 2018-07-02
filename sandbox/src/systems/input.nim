import logging
import sdl2.sdl
import strformat

import c4.systems
import c4.systems.network.enet
import c4.config
import c4.presets.action.systems.input

import "../messages"


type
  # We inherit input system from ``ActionInputSystem`` cause it already handles common input events, like mouse move and WASD key presses. However, we are not satisfied with default ``ActionInputSystem`` cause we need some additional key handlers, like pressing C, L or other keys.
  SandboxInputSystem* = object of ActionInputSystem


method handle*(self: ref SandboxInputSystem, event: sdl.Event) =
  # Here we want to manually handle some key presses
  case event.kind
    of sdl.KEYDOWN:
      case event.key.keysym.sym
        of K_c:
          # When player presses "C" key, we want to establish connection to remote server. We create new ``ConnectMessage`` (which is already predefined in Enet networking system), set server address and send this message to network system. Default Enet networking system knows that it should connect to the server when receiving this kind of message.
          let connectMsg = (ref ConnectMessage)(address: ("localhost", config.settings.network.port))
          logging.debug &"Sending {connectMsg}"
          connectMsg.send(config.systems.network)
        
        of K_q:
          # When player presses "Q" key, we want to disconnect from server. We create new ``DisconnectMessage`` (which is already predefined in Enet networking system), and sent this message to network system. Default Enet networking system knows that it should disconnect from the server when receiving this kind of message.
          let disconnectMsg = new(DisconnectMessage)
          logging.debug &"Sending {disconnectMsg}"
          disconnectMsg.send(config.systems.network)

        of K_r:
          # When player presses "R" key, we want server to reset the scene. We defined custom ``ResetSceneMessage`` and send it over the network.
          logging.debug "Sending reset scene message"
          new(ResetSceneMessage).send(config.systems.network)
      
        else:
          discard

    else:
      discard

  # As far as we inherit from ``ActionInputSystem``, there are bunch of event handlers defined for us by default. For example, if player presses "W" key, ``ActionInputSystem`` will send ``MoveForwardMessage``. Same for mouse movements. That's why it's definitely a good idea to call parent method to fire the defaults.
  procCall self.as(ref ActionInputSystem).handle(event)