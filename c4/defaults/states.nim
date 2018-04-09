from "../core/states" import State


type
  FinalState* = object of State

  ServerState* = object of State
  InitialServerState* = object of ServerState
  LoadingServerState* = object of ServerState
  RunningServerState* = object of ServerState

  ClientState* = object of State
  InitialClientState* = object of ClientState
  RunningClientState* = object of ClientState
