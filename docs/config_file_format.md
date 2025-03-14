# Config file format

The LuaRocks configuration file is a Lua file containing assignments. Default
values are assumed for variables that are not assigned explicitly.

The location of the configuration file can be configured through flags during
installation. If no `--force-config` or `/FORCECONFIG` flags were used on
installation, the `LUAROCKS_CONFIG` environment variable can be used as well
(or for a particular Lua version, `LUAROCKS_CONFIG_5_2`, similar to the
`LUA_PATH_5_2` feature introduced in Lua 5.2).

The default value is platform-dependent; exact paths depend on flags given
during installation, but on Unix systems it would be something like
`/etc/luarocks/config.lua` or `/etc/luarocks/config-5.1.lua` for older
versions of lua; on Windows systems, `c:\luarocks\config.lua`.

Specifically on Unix systems, the following directories are searched (in this
order) for a user config file:

* `$XDG_CONFIG_HOME/luarocks/`.
* `$HOME/.config/luarocks/`.
* `$HOME/.luarocks/`.

# Locations 

* `rocks_trees` (array of strings or tables) - The path to the local rocks
  trees, where rocks are installed. When installing rocks, LuaRocks tries to
  pick a location to store the rock starting from the bottom of the list; when
  loading rocks in runtime, LuaRocks scans from the top of the list. This way,
  if one has the local dir first and the system-wide dir last (this is what
  the default installation does, for instance), rocks installed by the user
  take precedence over rocks installed system-wide, and rocks installed by the
  admin user go to the system-wide dir while user installations go to their
  home directory. An entry in this table can be:
  * a string, denoting the prefix of a tree. For example: `home.."/.luarocks"`
  * a table, where deployment subdirectories of a tree can be further
    customized. The 'root' field is mandatory; 'bin_dir', 'lib_dir' and
    'lua_dir' are optional. Example: `{ root = home.."/local", bin_dir =
    home.."/local/arch/bin", lib_dir = home.."/local/arch/lib/lua/5.1",
    lua_dir = home.."/local/share/lua/5.1" }`

* `rocks_servers` (array of strings) - Remote URLs or local pathnames of rocks
  servers: directories containing .rock or .rockspec files, and a "manifest"
  file, generated by the luarocks-admin make_manifest command. Default is {
  "http://luarocks.org/repositories/rocks" }.

* `external_deps_dirs` (array of strings) - Where to look for external
  dependencies, when a prefix is not set for a specific dependency in the
  _variables_ table (see below) or through the command-line. Default is {
  "/usr/local", "/usr" } on Unix; { "c:\\external" } on Windows.

* `external_deps_subdirs` (table with string keys and string values) -
  Subdirectories to be used in conjunction with external_deps_dirs. Specifies
  where to look for specific types external dependencies. This can be
  overriden, for example, on Linux distributions which feature multiarch
  libraries and libraries are no longer in the "lib" subdir. Default is { bin
  = "bin", lib = "lib", include = "include" }.

* `runtime_external_deps_subdirs` (table with string keys and string values) -
  Same as the above, to be used with _luarocks install_.

* `lib_modules_path` (string) - The path where modules with native C
  extensions will be installed. If you are using a x86_64 *nix OS, you will
  probably need this line in `config.lua`:
  `lib_modules_path="/lib64/lua/"..lua_version`. See [issue
  416](https://github.com/keplerproject/luarocks/issues/416).

# File upload 

* `upload_server` (string) - An FTP URL for a rock server (optionally
  including username and password), or an alias specified in the
  upload_servers table. Example:
  `"ftp://_user_:_password_@ftp.luarocks.org/repositories/rocks"`

* `upload_user` (string) - Default login name rock servers.

* `upload_password` (string) - Default password rock servers.

* `upload_servers` (table with string keys and table values) - A list of
  aliases for URLs, to be used for accessing repositories through various
  protocols. Each entry has a string alias as a key and a table as a value.
  This table value contains protocol names as keys and pathnames as values.
  Protocols "http", "ftp" and "sftp" are supported. Example: `{ rocks = { http
  = "www.example.com/rocks", sftp = "example.com/var/rocks" } }`

# Platform-specific settings 

* `lua_extension` (string) - Filename extension of Lua files (without the
  dot/separator). Default is "lua".

* `lib_extension` (string) - Filename extension of dynamic library files
  (without the dot/separator). Default is "so" on Unix; "dll" on Windows.

* `arch` (string) - A two-part string identifying operating system and
  hardware architecture, for filtering binary rocks. This value is
  autodetected by LuaRocks. Example values are "macosx-powerpc" and
  "win32-x86".

* `platforms` (array of string) - A list of string identifiers indicating
  which platform constraints can be satisfied by the running system. This is
  used for filtering commands on the LuaRocks build rules. This allows a more
  general platform definition such as "unix" when the same build commands are
  valid for all Unix variants, instead of enumerating all known valid arch
  entries, and at the same time using a more specific definition such as
  "macosx" when a platform-specific flag is used. This value is automatically
  filled according to the value of _arch_.

* `external_deps_patterns` (table) - Name patterns to be used when matching
  dependencies in a  [portable
  way](platform_agnostic_external_dependencies.md).

* `runtime_external_deps_patterns` (table) - Name patterns to be used by
  _luarocks install_ when matching dependencies in a [portable
  way](platform_agnostic_external_dependencies.md).

* `link_lua_explicitly` (boolean) - Link the Lua library to the built modules
  when using the builtin mode (this is set to true for Cygwin).

# Variables 

* `variables` (table) - A table containing string-to-string key-value pairs
  containing variables to be substituted by build rules in rockspecs. LuaRocks
  provides a general facility for build back-ends in which they can substitute
  the entries of this table in strings containing references written
  $(LIKE_THIS). Some standard variables are expected by the included
  back-ends. For example, the "make" back-end expects the LIBFLAG to contain
  the flag to be passed to the C compiler to instruct it to build a shared
  library. So, in Linux systems, `variables["LIBFLAG"] = "-shared"`.

After reading the user entries, LuaRocks dynamically adds entries to this
table that refer to the rock being compiled, to make values available to the
build back-end. These are:

* `PREFIX` - The installation prefix of the rock (absolute path inside the
  rocks tree). Example: `"/home/hisham/.luarocks/5.1/foo/1.0-1/"`

  * `LUADIR` - Directory for storing Lua modules written in Lua (absolute path
    inside the rock entry of the rocks tree). Example:
    `"/home/hisham/.luarocks/5.1/foo/1.0-1/lua/"`

  * `LIBDIR` - Directory for storing Lua modules written in C (absolute path
    inside the rock entry of the rocks tree). Example:
    `"/home/hisham/.luarocks/5.1/foo/1.0-1/lib/"`

  * `BINDIR` - Directory for storing command-line scripts (absolute path
    inside the rock entry of the rocks tree). Example:
    `"/home/hisham/.luarocks/5.1/foo/1.0-1/bin/"`

  * `CONFDIR` - Directory for storing configuration files for a module
    (absolute path inside the rock entry of the rocks tree). Example:
    `"/home/hisham/.luarocks/5.1/foo/1.0-1/conf/"`

Such entries should not be added by the user in the configuration file, as
they are dynamically constructed for each different rock. If you need to
customize the various locations where files are deployed in a tree, use the
table syntax for `rocks_trees` entries (see above).

<font color="green">(since 2.0.5)</font> You can also override external
commands called by LuaRocks by using entries in the _variables_ table, in case
you need to customize the way they are called. Note that by installing
appropriate Lua modules, most of these external command invocations can be
avoided. Currently recognized entries in the _variables_ table are:

* `MAKE` for build.type="make";

* `CC, LD` (and `RC` on Windows) for build.type="builtin";

* `CVS, GIT, SSCM, SVN` for their respective download protocols;

* `RSYNC, SCP` for luarocks-admin operations;

* `WGET` or `CURL` when LuaSocket is not installed;

* `PWD, MKDIR, RMDIR, CP, LS, RM, FIND, TEST, CHMOD, STAT` when LuaFileSystem
  is not installed;

* `ZIP` when Lua-Zlib is not installed;

* `UNZIP` when LuaZip is not installed;

* `GUNZIP, BUNZIP2, TAR` on Unix or `SEVENZ` on Windows for source extraction
  during "luarocks build";

* `MD5SUM, OPENSSL` or `MD5` according to the operating system, when the Lua
  md5 module is not installed.

# External input 

As the config file itself is a Lua code file, there is some possibility to
execute Lua code. Because it is run in a sandbox this is very limited, but
might still be useful.

What LuaRocks makes available:

* parameters/values: several values are made available to the config file
  (pre-loaded in the sandbox) and include things like processor and OS
  platform, rocks trees which are in use, etc. (see `dump_env()` below)

* function: `os_getenv(varname)`; this is the regular Lua function
  `os.getenv()` and allows one to fetch environment variable values from the
  OS.

* function: `dump_env()`; this will dump a list of all variables provided by
  LuaRocks as a debug aid.

To test this, add a line `dump_env()` to your config file and execute
`luarocks` on the commandline to see the results.

# Other 

* `cmake_generator` (string) - If specified it overrides the default cmake
  generator. Currently only Makefile-based generators are supported.

* `wrap_bin_scripts` (boolean) - The default value is true: scripts installed
  at bin/ are launched by a wrapper script that sets path environment
  variables to ensure Lua modules are found. If set to false, scripts
  installed at bin/ are copied directly, and no wrappers are generated.

* `use_extensions` (boolean) - If specified, rockspec format verison 1.1 is
  enabled, adding the deploy.wrap_bin_scripts option to the rockspec format,
  which acts like the wrap_bin_scripts option above, in a rock by rock basis.

* `local_by_default` (boolean) - If `true`, the tree in the user's home
  directory is used as if the command line option `--local` had been given


