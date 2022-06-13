<h1>Configuration file</h1>

As of version `1.9.7` ellipsis has support for a configuration file.

The first found file from the following list will be loaded;
- `$ELLIPSIS_CONFIG`
- `$XDG_CONFIG_HOME/ellipsisrc`
- `$XDG_CONFIG_HIME/ellipsis/ellipisrc`
- `$HOME/.ellipsisrc`
- `$HOME/.ellipsis/ellipsisrc`

This file will be **sourced**, after all other code. Because of this it's
very powerful, you can even overload internal functions. (Use with care!)

Because ellipsis will run some code during it's initialization, the following
variables can not be configured this way;
- `ELLIPSIS_PATH`

You can use `ellipsis info` to check if your custom config file is being used.
```sh
 user:~  ellipsis info
 v1.9.7 (2fcf4e9)
   Home: /home/user
   User: user
   Init: 1
   Path: /home/user/.ellipsis
   Config: /home/user/.ellipsisrc
   Packages: /home/user/.ellipsis/packages
```

**Attention**:
The init system will not load the config file. This means that custom functions
and variables configured this way will not be available in `pkg.init` hooks.

The init system can not detect custom `ELLIPSIS_PACKAGES` settings configured
this way. If your using a custom packages location and init hooks, you should
configure this in your shells config file. (eg. `export
ELLIPISIS_PACKAGES="/my/location"`)
