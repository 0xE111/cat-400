"Cat-400" (c4) is a game framework for Nim programming language. Being a framework means that c4 will do all the dirty job for you while you focus on creating your game. Under active development.

### Ensure you can launch it
First, install latest c4:

    cd /tmp
    # install latest c4
    git clone https://github.com/c0ntribut0r/cat-400
    cd cat-400
    nimble install
    # you should get smth like
    # Success: c4 installed successfully.

Create test project:

    mkdir /tmp/testapp
    cd /tmp/testapp
    touch testapp.nim
    
Now edit `testapp.nim`:

    from c4.main import run
    run()  # here we just launch c4

Run your app:

    nim c -r testapp.nim --loglevel=DEBUG
