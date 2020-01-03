import strformat
import sequtils
import tables
import logging

import sdl2/sdl as sdllib

import c4/entities
import c4/systems/video/sdl
import c4/threads

import ../messages


type
  VideoSystem* = object of SdlVideoSystem

  Video* = object of SdlVideo
    width*: float
    height*: float
    color*: Color


const
  backgroundColor* = Color(
    r: uint8(uint8.high.float * 0.1),
    g: uint8(uint8.high.float * 0.1),
    b: uint8(uint8.high.float * 0.1),
    a: uint8.high,
  )
  wallColor* = Color(
    r: uint8(uint8.high.float * 0.3),
    g: uint8(uint8.high.float * 0.3),
    b: uint8(uint8.high.float * 0.3),
    a: uint8.high,
  )
  paddleColor* = Color(r: 0, g: uint8.high, b: 0, a: uint8.high)
  ballColor* = Color(r: uint8.high, g: 0, b: 0, a: uint8.high)


method render*(self: ref VideoSystem, video: ref Video) =
  discard self.renderer.setRenderDrawColor(video.color)

  var windowWidth, windowHeight: cint
  self.window.getWindowSize(windowWidth.addr, windowHeight.addr)

  var rect = Rect(
    x: int(windowWidth.float * (video.x - video.width / 2)),
    y: int(windowHeight.float * (video.y - video.height / 2)),
    w: int(windowWidth.float * video.width),
    h: int(windowHeight.float * video.height),
  )
  discard self.renderer.renderFillRect(rect.addr)


method update*(self: ref VideoSystem, dt: float) =
  if self.renderer.renderClear() != 0:
    raise newException(LibraryError, &"Could not clear renderer: {getError()}")

  for video in getComponents(ref Video).values:
    self.render(video)

  discard self.renderer.setRenderDrawColor(backgroundColor)
  self.renderer.renderPresent()
