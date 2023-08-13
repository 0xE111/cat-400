import os
export os
import osproc
import options
export options
import tables
export tables
import parseopt
import sequtils

import ./logging

when isMainModule:
  import unittest

type
  ProcessName* = string  ## each process must have a unique name; process will be accessible by this name


var processes = initTable[ProcessName, Process]()
const mainProcessName* = "master"


proc getProcessName(): string =
  for kind, key, value in parseopt.getopt():
    if kind == parseopt.cmdLongOption and key == "process":
      return value

  mainProcessName


let processName*: ProcessName = getProcessName()


template spawnProcess*(name: ProcessName, code: untyped) =
  ## Runs new process which executes all instructions before this call, plus `code` content.

  debug "process started"

  if processName == mainProcessName:
    if processes.hasKey(name):
      raise newException(KeyError, "Process with name '" & name & "' already exists")

    debug "spawning child process", childProcess=name
    processes[name] = startProcess(
      command=getAppFilename(),
      args=commandLineParams() & " --process=" & name,
      options={poParentStreams},
    )

  elif processName == name:
    try:
      code
      debug "process finishing"
      system.quit()
    except Exception as exc:
      fatal "process failed", exceptionMessage=exc.msg, stackTrace=exc.getStackTrace()
      raise

proc joinProcesses*(checkInterval: int = 1000) =
  ## Monitors existing processes. If one process is not running anymore, terminates all other processes as well.
  assert processName == mainProcessName

  while true:
    let running = toSeq(processes.values()).filterIt(it.running)
    if running.len == 0:
      break

    sleep checkInterval


proc sync*(checkInterval: int = 1000) =
  assert processName == mainProcessName
  while toSeq(processes.values()).anyIt(it.running):
    sleep checkInterval


when isMainModule:
  suite "processes":
    spawnProcess "process1":
      for _ in 0..10:
        echo processName
        sleep 100

    spawnProcess "process2":
      for _ in 0..10:
        echo processName
        sleep 100

    sync()

    test "run":
      assert true
