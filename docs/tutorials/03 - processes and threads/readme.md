Threads
=======

> `c4/threads` may be used separately from `cat 400` framework,

Originally, `Cat 400` was single-threaded, like most of existing nim game engines. However, this is very inefficient: every personal computer has at least couple cores, and you should use all of them for best performance of our app, making calculations as parallel as possible. Even if number of threads is greater than number of cores, [it's still fine](https://stackoverflow.com/questions/3126154/multithreading-what-is-the-point-of-more-threads-than-cores). Also, running different parts of application inside separate threads is a good way of decoupling things.

Processes
=========

