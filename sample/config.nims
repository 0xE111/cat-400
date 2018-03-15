from strformat import `&`

let projectDir = thisDir()
echo &"Project dir: {projectDir}"
switch("define", &"projectDir={projectDir}")

