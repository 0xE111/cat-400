from strutils import split, splitLines

version = staticRead("../../version.txt").split('-')[0]
author = "c0ntribut0r"
description = "Cat-400 default systems"
license = staticRead("../../../LICENSE").splitLines()[0]

requires "c4 >= " & version
