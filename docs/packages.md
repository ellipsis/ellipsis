<h1>Packages</h1>

A package is any repo with files you want to symlink into `$ELLIPSIS_HOME`
(typically `$HOME`). By default all of a repository's non-hidden files (read:
not beginning with a `.`) will naively be linked into place, with the exception
of a few common text files (`README`, `LICENSE`, etc).

You can customize how ellipsis interacts with your package by adding an
`ellipsis.sh` file to the root of your project. Here's an example of a complete
`ellipsis.sh` file:

```bash
#!/usr/bin/env bash
```

Yep, that's it :) If all you want to do is symlink some files into `$HOME`,
adding an `ellipsis.sh` to your package is completely optional. But what if you
need more? That's where [hooks][hooks] come in!

The `ellipsis.sh` file also lets you specify the minimal Ellipsis version
needed to use your package. This can be done by defining the
`ELLIPSIS_VERSION_DEP` variable.

```bash
#!/usr/bin/env bash

ELLIPSIS_VERSION_DEP="1.8.0"
```

[hooks]:         hooks.md
