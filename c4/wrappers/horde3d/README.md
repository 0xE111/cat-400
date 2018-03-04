# Horde3D

This is a wrapper for [Horde3d](http://horde3d.org/). Built against latest release version (1.0.0 - 17.09.17).

## About

These are Horde3D bindings for nim. Pay attention:

- "H3D" prefixes wiped out;
- To avoid ambiguity `{.pure.}` pragma on enums is used. That means that you have to always be explicit with Horde3D enums, like this: `MatRes.SamplerElem` (just `SamplerElem` is not allowed);
- This project is more up-to-date and is built against Horde3D 1.0.0 release version.

## Installation

Install directly from git subdir:

```sh
nimble install "https://github.com/c0ntribut0r/cat-400?subdir=c4/wrappers/horde3d@#head"
```

## License

MIT. Do whatever you want.
