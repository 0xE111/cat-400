# Msgpack

This is an extension for [msgpack4nim](https://github.com/jangko/msgpack4nim).

## About

By default msgpack4nim doesn't support inheritance, which makes you think about how to convert your object to/from string. This extension allows you to serialize and deserialize your base and inhereted objects, preserving runtime types and field values.

## Installation

Install directly from git subdir:

```sh
nimble install "https://github.com/c0ntribut0r/cat-400?subdir=c4/wrappers/msgpack@#head"
```

## License

MIT. Do whatever you want.
