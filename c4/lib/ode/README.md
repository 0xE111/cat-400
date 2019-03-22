# Open Dynamics Engine

This is a wrapper for [OpenDynamicsEngine](http://ode.org/).

Please note that this wrapper is very dirty and was not tested at all.

## Installation

Install directly from git subdir:

```sh
nimble install "https://github.com/c0ntribut0r/cat-400?subdir=c4/lib/ode@#head"
```

Please ensure you set the same precision as ODE compiled library you're going to use (`.so` or `.dll`). To set precision, define either `dIDEDOUBLE` (the default) or `dIDESINGLE` for nim compiler.

## License

MIT. Do whatever you want.
