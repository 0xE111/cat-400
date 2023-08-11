# processes_creation.nim
import c4/processes
import c4/logging

info "running common piece of code", processName  # for each process this will have its unique value

# at this point we start new subprocess;
# as mentioned earlier, every code before this line
# will be executed in every subprocess
spawnProcess "subprocess1":
  for i in 0..5:
    info "process payload", i
    sleep 100

# everything before this line (except run("subprocess1") block)
# will be executed in "subprocess2" process
spawnProcess "subprocess2":
  for i in 0..5:
    info "process payload", i
    sleep 100

info "only one process reaches this place", processName

# wait for the processes to complete;
# if one process is not running, others are force shut down
joinProcesses()
info "all processes completed"
