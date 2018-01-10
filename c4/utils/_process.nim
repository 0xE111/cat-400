from logging import nil
from loop import runLoop, UpdateProc, getFps
from states import State, switch
# from "../conf" import config
# from "../backends/network" import NetworkBackend  # TODO: avoid brackets in "import" statements


type
  Process* = object of RootObj
    state: ref State  # TODO: add "not nil"

proc update(self: ref Process, dt:float): bool =
  # echo($getFps(dt))
  result = true
  # return not (self.state of ref None)

proc start*(self: Process) =
  logging.debug("Process started")
  # process.state = new(ref None)
  # switch(process.state, new(ref Loading))

  # runLoop(
  #   updatesPerSecond = 30,
  #   fixedFrequencyHandlers = @[
  #     proc(dt: float): bool = self.update(dt)  # anonymous proc
  #   ]
  # )
  logging.debug("Process stopped")
