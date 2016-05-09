<h1>API</h1>

Besides the default hook implementations which are available to you from your
`ellipsis.sh` as `hooks.<name>`, there are a number of useful functions and
variables which ellipsis exposes for you:

#### Index
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
`fs.link_rfile`               | Symlinks a single file into `$ELLIPSIS_HOME`.
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

#### ellipsis

<h5>ellipsis.each</h5>
Executes command for each installed package.

``` bash
# example (Updates all packages)
ellipsis.each pkg.pull
```
---

<h5>ellipsis.list_packages</h5>
Lists all installed packages.

``` bash
# example (Prints all package names)
for package in ellipsis.list_packages; do
    echo "$package"
done
```
---

#### fs

<h5>fs.backup</h5>
Creates a backup of an existing file, ensuring you don't overwrite existing
backups.

``` bash
# example (Makes a backup of 'file')
fs.backup file
```
---

<h5>fs.file_exists</h5>
Returns true if file exists.

---

<h5>fs.folder_empty</h5>
Returns true if folder is empty.

---


<h5>fs.is_broken_symlink</h5>
Returns true if file is a broken symlink.

---

<h5>fs.is_ellipsis_symlink</h5>
Returns true if file is a symlink pointing to an ellipsis package.

---

<h5>fs.is_symlink</h5>
Returns true if file is a symlink.

---

<h5>fs.link_rfile</h5>
Symlinks a single file into `$ELLIPSIS_HOME`.

---

<h5>fs.link_file</h5>
Symlinks a single file into `$ELLIPSIS_HOME`.

---

<h5>fs.link_files</h5>
Symlinks all files in given folder into `$ELLIPSIS_HOME`.

---

<h5>fs.list_dirs</h5>
Lists directories, useful for passing subdirectories to `fs.link_files`.

---

<h5>fs.list_symlinks</h5>
Lists symlinks in a folder, defaulting to `$ELLIPSIS_HOME`.

---

<h5>fs.strip_dot</h5>
Removes `.` prefix from files in a given directory.

---

#### git

<h5>git.clone</h5>
Clones a Git repo, identical to `git clone`.

---

<h5>git.diffstat</h5>
Displays `git diff --stat`.

---

<h5>git.has_changes</h5>
Returns true if repository has changes.

---

<h5>git.head</h5>
Prints how far ahead a package is from origin.

---

<h5>git.last_updated</h5>
Prints commit's relative last update time.

---

<h5>git.pull</h5>
Identical to `git pull`.

---

<h5>git.push</h5>
Identical to `git push`.

---

<h5>git.sha1</h5>
Prints last commit's sha1 using `git rev-parse --short HEAD`.

---

#### os

<h5>os.platform</h5>
Returns one of `cygwin`, `freebsd`, `linux`, `osx`.

---

#### path

<h5>path.abs_path</h5>
Return absolute path to `$1`.

---

<h5>path.is_path</h5>
Simple heuristic to determine if `$1` is a path.

---

<h5>path.relative_to_home</h5>
Replaces `$HOME` with `~`

---

<h5>path.expand</h5>
Replaces `~` with `$HOME`

---

<h5>path.relative_to_packages</h5>
Strips `$ELLIPSIS_PACKAGES` from path.

---

<h5>path.strip_dot</h5>
Strip dot from hidden files/folders.

---

#### Utils

<h5>utils.cmd_exists</h5>
Returns true if command exists.

---

<h5>utils.prompt</h5>
Prompts user `$1` message and returns true if `YES` or `yes` is input.

---

<h5>utils.run_installer</h5>
Downloads and runs web-based shell script installers.

---

<h5>utils.version_compare</h5>
Compare version strings. Usage: `utils.version_compare "$Version1" ">="
"1.2.4"`.

---
