# processes_creation.nim
import c4/processes

echo "Common piece of code executed by " & processName  # for each process this will have its unique value

# at this point we start new subprocess;
# as mentioned earlier, every code before this line
# will be executed in every subprocess
run("subprocess1"):
  for i in 0..5:
    echo "#" & $i & " Doing something inside " & processName  # print current process name
    sleep 500

# everything before this line (except run("subprocess1") block)
# will be executed in "subprocess2" process
run("subprocess2"):
  for i in 0..5:
    echo "#" & $i & " Doing something inside " & processName
    sleep 500

echo "Only one process reaches this place: " & processName

# wait for the processes to complete;
# if one process is not running, others are force shut down
dieTogether()
echo "All processes completed"
