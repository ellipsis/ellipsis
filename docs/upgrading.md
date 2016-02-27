<h1>Upgrading</h1>

No stranger to dotfiles? Spent years hording complex configurations for esoteric
and archaic programs? Have your own system for managing them using a bunch of
scripts you've cobbled together over the years? I've been there, friend.

Luckily it's easy to convert your existing dotfiles into a shiny new ellipsis
package:

```bash
$ export ELLIPSIS_USER=your-github-user

$ ellipsis new dotfiles
Initialized empty Git repository in /home/user/.ellipsis/packages/dotfiles/.git/
[master (root-commit) 5f5d2a9] Initial commit
 2 files changed, 35 insertions(+)
 create mode 100644 README.md
 create mode 100644 ellipsis.sh
new package created at ~/.ellipsis/packages/dotfiles

$ ellipsis add dotfiles .*
mv ~/.vimrc dotfiles/vimrc
linking dotfiles/vimrc -> ~/.vimrc
mv ~/.zshrc dotfiles/zshrc
linking dotfiles/zshrc -> ~/.zshrc
```
