from system import staticExec

# Package
version       = staticExec("git describe --tags --abbrev=0")
author        = "c0ntribut0r"
description   = "Game framework"
license       = "MIT"

# Dirs
skipDirs      = @["samples"]

# Dependencies
requires "nim >= 0.17.2"
