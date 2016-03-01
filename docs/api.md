<h1>API</h1>

Besides the default hook implementations which are available to you from your
`ellipsis.sh` as `hooks.<name>`, there are a number of useful functions and
variables which ellipsis exposes for you:

Function/Variable             | Description
------------------------------|------------
`ellipsis.each`               | Executes command for each installed package.
`ellipsis.list_packages`      | Lists all installed packages.
`fs.backup`                   | Creates a backup of an existing file, ensuring you don't overwrite existing backups.
`fs.file_exists`              | Returns true if file exists.
`fs.folder_empty`             | Returns true if folder is empty.
`fs.is_broken_symlink`        | Returns true if file is a broken symlink.
`fs.is_ellipsis_symlink`      | Returns true if file is a symlink pointing to an ellipsis package.
`fs.is_symlink`               | Returns true if file is a symlink.
`fs.link_file`                | Symlinks a single file into `$ELLIPSIS_HOME`.
`fs.link_files`               | Symlinks all files in given folder into `$ELLIPSIS_HOME`.
`fs.list_dirs`                | Lists directories, useful for passing subdirectories to `fs.link_files`.
`fs.list_symlinks`            | Lists symlinks in a folder, defaulting to `$ELLIPSIS_HOME`.
`fs.strip_dot`                | Removes `.` prefix from files in a given directory.
`git.clone`                   | Clones a Git repo, identical to `git clone`.
`git.diffstat`                | Displays `git diff --stat`.
`git.has_changes`             | Returns true if repository has changes.
`git.head`                    | Prints how far ahead a package is from origin.
`git.last_updated`            | Prints commit's relative last update time.
`git.pull`                    | Identical to `git pull`.
`git.push`                    | Identical to `git push`.
`git.sha1`                    | Prints last commit's sha1 using `git rev-parse --short HEAD`.
`os.platform`                 | Returns one of `cygwin`, `freebsd`, `linux`, `osx`.
`path.abs_path`               | Return absolute path to `$1`.
`path.is_path`                | Simple heuristic to determine if `$1` is a path.
`path.relative_to_home`       | Replaces `$HOME` with `~`
`path.expand`                 | Replaces `~` with `$HOME`
`path.relative_to_packages`   | Strips `$ELLIPSIS_PACKAGES` from path.
`path.strip_dot`              | Strip dot from hidden files/folders.
`utils.cmd_exists`            | Returns true if command exists.
`utils.prompt`                | Prompts user `$1` message and returns true if `YES` or `yes` is input.
`utils.run_installer`         | Downloads and runs web-based shell script installers.
`utils.version_compare`       | Compare version strings. Usage: `utils.version_compare "$Version1" ">=" "1.2.4"`.

