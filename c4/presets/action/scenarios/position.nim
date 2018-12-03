import logging
import strformat

import ../../../config
import ../../../core/messages
import ../../../core/entities
import ../../../systems
import ../../../systems/video/horde3d as horde3d_video
import ../systems/video
import ../systems/input
import ../messages as action_messages

import ../../../wrappers/horde3d/horde3d
import ../../../wrappers/horde3d/horde3d/helpers


method process(self: ref ActionVideoSystem, message: ref SetPositionMessage) =
    if not message.entity.has(ref Video):
        logging.warn &"{self} received {message}, but has no Video component"
        # raise newException(LibraryError, "Shit im getting errors")
        # TODO: When client just connected to server, the server still may broadcast some messages
        # before syncing world state with client. When these messages reach client, it doesn't have
        # corresponding components yet, thus won't be able to process these messages and fail.
        return

    var video = message.entity[ref Video]
    let curTransform = video.node.getTransform()

    video.node.setNodeTransform(
        message.x, message.y, message.z,
        curTransform.rx, curTransform.ry, curTransform.rz,
        curTransform.sx, curTransform.sy, curTransform.sz,
    )
