"Cat-400" (c4) is a game framework for Nim programming language. Being a framework means that c4 will do all the dirty job for you while you focus on creating your game. Under active development.

### List of other nim game engines/frameworks

Link | Development
---- | -------
https://github.com/yglukhov/rod | 
https://github.com/fragworks/frag | X
https://github.com/zacharycarter/zengine | 
https://github.com/Vladar4/nimgame | X
https://github.com/Vladar4/nimgame2 | 
https://github.com/def-/nim-platformer | X
https://github.com/ftsf/nico | 
https://github.com/rnentjes/nim-ludens |
https://github.com/dustinlacewell/dadren |
https://github.com/Polkm/nimatoad |
https://github.com/dadren/dadren |
https://github.com/copygirl/gaem | Looks promising
https://github.com/hcorion/Jonah-Engine | 
https://github.com/jsudlow/cush |
https://github.com/sheosi/tart |


### Ensure you can launch it
First, install latest c4:

    nimble install https://github.com/c0ntribut0r/cat-400@#head

Create test project:

    mkdir /tmp/testapp
    cd /tmp/testapp
    touch testapp.nim
    
Now edit `testapp.nim`:

    from c4.main import run
    from c4.config import Config


    const conf: Config = (version: "0.1")

    when isMainModule:  
        run(conf)


Check whether you can launch c4 and show version:

    nim c -r testapp.nim -v
