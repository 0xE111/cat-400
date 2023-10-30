import c4/entities
import c4/threads
import c4/logging
import c4/lib/ogre/ogre

import ../systems/network
import ../systems/video
import ../messages
import ../threads


method receive*(self: ref network.ClientNetworkSystem, message: ref EntityCreateMessage) =
  debug "creating entity"
  let entity = newEntity()
  self.entitiesMap[message.entity] = entity  # remember mapping from server's entity to client's one
  message.entity = entity
  message.send(videoThread)  # forward message to video thread


method process*(self: ref VideoSystem, message: ref EntityCreateMessage) =

  let node = self.sceneManager.getRootSceneNode().createChildSceneNode()
  if message.shape.len > 0:

    let manualObject = self.sceneManager.createManualObject()

    # -------- draw as triangles --------
    # manualObject.begin("BaseWhiteNoLighting", OT_TRIANGLE_LIST)
    # # manualObject.colour(0.5, 0.5, 0.5)
    # for i in 0 ..< int(message.shape.len / 3):
    #   manualObject.position(message.shape[i * 3], message.shape[i * 3 + 1], message.shape[i * 3 + 2])
    # for i in 0 ..< int(message.shape.len / 9):
    #   manualObject.triangle(i.uint32 * 3, i.uint32 * 3 + 1, i.uint32 * 3 + 2)

    # -------- draw as lines --------
    manualObject.begin("BaseWhiteNoLighting", OT_LINE_LIST)
    for i in 0..<int(message.shape.len / 3):
      let a = message.shape[i * 3]
      let b = message.shape[i * 3 + 1]
      let c = message.shape[i * 3 + 2]

      manualObject.position(a[0], a[1], a[2])
      manualObject.position(b[0], b[1], b[2])

      manualObject.position(b[0], b[1], b[2])
      manualObject.position(c[0], c[1], c[2])

      manualObject.position(c[0], c[1], c[2])
      manualObject.position(a[0], a[1], a[2])

    discard manualObject.end()
    discard manualObject.convertToMesh("manualObject")

    let videoEntity = self.sceneManager.createEntity("manualObject")
    node.attachObject(videoEntity)
    # assert false

  else:
    let box = self.sceneManager.createEntity("box")
    node.attachObject(box)

  message.entity[ref Video] = (ref Video)(node: node)
  debug "created new video", entity=message.entity
