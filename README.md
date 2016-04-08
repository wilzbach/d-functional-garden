d-functional-garden
===================

[![Build Status](https://travis-ci.org/wilzbach/d-functional-garden.svg?branch=master)](https://travis-ci.org/wilzbach/d-functional-garden)

Functional garden for the D Language

The Functional DLang Garden provides a variety of snippets that can be used to learn D or as a quick reference.

All samples are valid code and automatically tested on every run (dmd, ldc).

Run it yourself
---------------

```
dub test && dub
```

Contribute
----------

Contributions are more than welcome - just send a PR.


How to add a new D snippet?
---------------------------

Go to [functional.d](https://github.com/wilzbach/d-functional-garden/blob/master/src/functional.d) and add your snippet as new unittest.
You can run the tests with `dub test` or `rdmd -unittest --main functional.d`.
