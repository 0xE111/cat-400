"Cat-400" (c4) is a game framework for Nim programming language. Being a framework means that c4 will do all the dirty job for you while you focus on creating your game. Under active development.

### List of other nim game engines/frameworks

Link | Comments
---- | -------
https://github.com/yglukhov/rod | No docs
https://github.com/zacharycarter/zengine | 
https://github.com/Vladar4/nimgame2 | 
https://github.com/ftsf/nico | 
https://github.com/rnentjes/nim-ludens |
https://github.com/dustinlacewell/dadren |
https://github.com/Polkm/nimatoad |
https://github.com/sheosi/tart |
https://github.com/copygirl/gaem | X
https://github.com/dadren/dadren | X
https://github.com/fragworks/frag | X
https://github.com/hcorion/Jonah-Engine | X
https://github.com/jsudlow/cush | X
https://github.com/def-/nim-platformer | X
https://github.com/Vladar4/nimgame | X

### Brief overview
C4 is being developed for custom needs. Please note that it's more educational project rather then professional software, however if you like it you may use it and make contributions.

The main benefit of c4 is its documentation - I try to make code and docs changes side by side, so docs should always be up-to-date. This is the thing many projects lack.

Less words - let's try to build something.

### Install & display version
First, install latest c4 right from github:

    > nimble install https://github.com/c0ntribut0r/cat-400@#head

Create test project. 

    > mkdir /tmp/test
    > cd /tmp/test
    > touch main.nim
    
Now edit `main.nim`. Let's just launch plain c4 without any custom code.

    from c4.core import run

    when isMainModule:
        run()

Check whether you can launch c4 and show version:

    > nim c -r main.nim -v
    ...
    Nim version 0.17.3
    Framework version 0.1.1-12
    Project version 0.0

Our `main.nim` looks empty, but the main job is done under the hood when calling `run()`. C4 initializes loggers, splits process into client and server, launches infinite loops and does many other things. We don't have to implement it ourselves which lets us focus on really important things! You may have a look at which options are available for your app by default:

    > ./main -h

Now let's start customizing.

### Framework configuration
