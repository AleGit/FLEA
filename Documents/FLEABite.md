# Flea Usage #

## Draft ##

### Options ###
You can run `Flea` with command line options like `--demo`.
The command line arguments between options
are the arguments of the option on the left of the arguments.

`./FleaBite --demo mgu hwv --config ~/custom.flea` has two options
- `--demo` with arguments `mgu` and `hwv`
- `--config` with argument `~/custom.flea`

#### Commandline options ####
- `--demo` show list of demos er execute demo
- `--problem`   problem file name
- `--tptp_root` absolute path to directory with axiom and problem folders
- `--prinfo active` Syslog.prinfo() prints messages befor syslog configuration is read.
- `--timeout`

An command line option always starts with the prefix `--` and uses lowercase letters `a-z` and underscore `_`.
- `--demo` n arguments: with no argument the available demos are listed, otherwise the demos are executed.

- `--tptp_root '/path/to/tptp/root'` 1 argument (optional, default=`~/TPTP`)

- `--problem name` 1 argument (without path or file extension)

- TODO: `--config path` 1 arguments: a path to a config file.

  e.g. `PUZ001-1` will be expanded to `/path/to/tptp/root/Problems/PUZ/PUZ001-1.p`
- TODO: `--files ppath [apath ...]` n+1 arguments: the first argument is the path to a problem file,
the additional ones are hint paths to axiom files. These are only used when there is a matching `include` line
in the problem file. If there is a `include` line without a matching hint path, then the axiom file is searched
in `path/to/totp/root/Axioms`.

- TODO: `--logging level` 1 argument with logging level. (optional)
- TODO: `--help [option]` show general or option specific help.

#### Environment options ####
A environment option always start with prefix `FLEA_` and uses uppercase letters and `A-Z` and underscore `_`.
Environment options have a lower priority than command line options.
- TODO: `FLEA_TPTP_ROOT`, see `--tptp_root`
- TODO: `FLEA_CONFIG`, see `--config`

#### Default options ####
If an option is neither set by command line nor environment the following defaults options are used:
- `tptp_root` = `"~/TPTP"`
- TODO: `config` = `Config/default.flea`

#### Paths ####
- A path with prefix `/` is an absolute path.
- A path with prefix `~/` starts in the user's `home` directory.
- All other paths start in the actual working directory.

