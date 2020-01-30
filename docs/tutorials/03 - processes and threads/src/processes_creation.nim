# processes_creation.nim
import strformat

import c4/processes


echo "This piece of code is executed in every process (master, subprocess1, subprocess2)"

echo &"Current process name: {processName}"  # for each process this will have its unique value

# at this point we start new subprocess;
# as mentioned earlier, every code before this line
# will be executed in every subprocess
run("subprocess1"):
  for _ in 0..5:
    echo processName  # print current process name
    sleep 1000

# everything before this line (except run("subprocess1") block)
# will be executed in "subprocess2" process
run("subprocess2"):
  for _ in 0..5:
    echo processName
    sleep 1000

echo "Only main process reaches this place"

# wait for the processes to complete;
# if one process is not running, others are force shut down
dieTogether()
