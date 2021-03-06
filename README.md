# Dotfiles

Configuration files for vim, bash, tmux, i3 and others.
These files are linked to from the home directory. This way I get to edit them from any part of the system and at the same contain them in a repository where I can version the changes.

To create links just run from this repository:

```bash
./setup
```

Currently the following environments are maintained:

| OS / environment      | terminal | shell      | editor       |
|-----------------------|----------|------------|--------------|
| Windows / Msys2/Mingw | MinTTY   | Bash       | vim          |
| WSL / Ubuntu          | ??       | Bash       | vim / neovim |
| Linux (Ubuntu, Arch)  |          | Bash       | vim / neovim |
| Windows (neovim-qt)   |          | Bash / Cmd | neovim       |
| Linux (neovim-qt)     |          | Bash       | neovim       |
