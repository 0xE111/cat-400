### Funny diary ###

#### 17.10.29 ####
Just created a small app - still trying to remember all nim basics, but looks like I totally forgot everything. Okay, nothing bad to start over, right?
So I created a "main" module which can parse command line arguments, as well as forks into two processes - one for server, one for client. Next step will be to connect server and client with something fast and reliable. I've found ENET (http://enet.bespin.org/) - a protocol on top of UDP which is reliable as TCP but not too complicated. Hope I'll find a way to use it in nim. And... I'm really happy to use nim again.

#### 26.11.17 ####
It is really painful to write code now. Every line of code produces an error, every statement is wrong. It's very hard to write something after using python which provides a lot of freedom and perfect syntax. Nim is not so beautiful, but still nice - at least better than C++.
I had to reinvent str.join and array.index functions cause nim was missing them (why?). This is where I felt difference between static and dynamic typing

Fucking nim! 

    nimble install compiler c2nim

    Installing compiler@0.17.2
    Success: compiler installed successfully.
    Installing c2nim@0.9.13
    ... c2nim.nim(87, 17) Error: type mismatch: got (PNode, string, string)
    ... but expected one of: 
    ... proc renderModule(n: PNode; filename: string; renderFlags: TRenderFlags = {})

    nimble uninstall compiler
    nimble install compiler@#head c2nim@#head

    Installing compiler@#head
    Success: compiler installed successfully.
    Installing c2nim@#head
    ... /home/wolfie/.nimble/pkgs/compiler-#head/compiler/ast.nim(1026, 33) Error: undeclared identifier: 'BackwardsIndex'


Totally fail (described in an issue): https://github.com/nim-lang/c2nim/issues/115

Finally I did it:

- installed latest nim from source
- installed compiler@#head
- installed c2nim@#head
