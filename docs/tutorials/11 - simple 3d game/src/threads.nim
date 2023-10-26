import c4/threads


const
  networkThread* = ThreadID(1)
  physicsThread* = ThreadID(2)
  videoThread* = ThreadID(3)
  inputThread* = ThreadID(4)
