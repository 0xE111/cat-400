from logging import nil
import systems.network
from utils.loop import runLoop
import wrappers.nimenet.nimenet.enet


type
  Config* = tuple[]

proc printPacket(peer: enet.Peer, channelId: uint8, packet: enet.Packet) =
  logging.debug("Received packet: " & $packet)

proc run*(config: Config) =
  logging.debug("Starting client")

  var networkConnection = network.Connection()
  networkConnection.init(
    onReceive=printPacket,
  )

  networkConnection.connect((host: "localhost", port: 11477'u16))
  runLoop(
      updatesPerSecond = 30,
      maxFrequencyHandlers = @[
        proc(dt: float): bool {.closure.} = networkConnection.poll(); return true,
      ]
    )
