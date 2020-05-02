<h1 align='center'>dotfiles</h1>
<h3 align='center'>:wrench: Bootstrapped dotfiles</h3>

This repository is a collection of most of the dotfiles on my machine.

When changing or reformatting the OS on my machine, managing these files have always been an issue.
Collecting them all at one place and bootstrapping them with a simple shell script saves a lot of configuration time :relieved:.

I use them for the following:
- **Shell**: zsh with [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) themed with [Power Level 10K](https://github.com/romkatv/powerlevel10k).
- **Editor**: Secondary - [nvim](https://neovim.io/) with [tmux](https://github.com/tmux/tmux/wiki) for better pane and window management :muscle: (Primary - [VS Code](https://howivscode.com/thepushkarp))
- **Git**
  + Custom commit message template to write better commits
  + gitconfig for aliases and other settings
  + A global gitignore file
- **Editor Config**: Global editorconfig file to ensure consistent styling in projects without editorconfigs

<h2>Installation</h2>

**Warning**: If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need.
Don’t blindly use these settings unless you know what that entails. Use at your own risk!

```sh
$ git clone https://github.com/thepushkarp/dotfiles.git && cd dotfiles
```

After cloning, make sure to change the paths in `bootstrap.sh` to point to your own dotfiles.
Do the necessary additions, deletions and changes to the files as per your needs.

```sh
$ chmod +x bootstrap.sh
$ ./bootstrap.sh
```

Inspired from [Anish Athalye's](https://github.com/anishathalye/dotfiles) and [Mathias Bynens's](https://github.com/mathiasbynens/dotfiles) dotfiles :sparkles:

---

<p align='center'>Made with :heart: by Pushkar Patel</p>
