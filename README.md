# Jeff Strauss's dotfiles for Windows

A collection of PowerShell files for Windows, including common application installation through `chocolatey` and `npm`, and developer-minded Windows configuration defaults.

Are you a Mac user? Check out my [dotfiles](https://github.com/jstrauss/dotfiles) repository.

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~\Projects\dotfiles-windows`.) The bootstrapper script will copy the files to your PowerShell Profile folder.

From PowerShell:
```posh
git clone https://github.com/jstrauss/dotfiles-windows.git; cd dotfiles-windows; . .\bootstrap.ps1
```

To update your settings, `cd` into your local `dotfiles-windows` repository within PowerShell and then:

```posh
. .\bootstrap.ps1
```

Note: You must have your execution policy set to unrestricted (or at least in bypass) for this to work: `Set-ExecutionPolicy Unrestricted`.

### Git-free install

> **Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work. To set this, run `Set-ExecutionPolicy Unrestricted` from a PowerShell running as Administrator.

To install these dotfiles from PowerShell without Git:

```bash
iex ((new-object net.webclient).DownloadString('https://raw.github.com/jstrauss/dotfiles-windows/master/setup/install.ps1'))
```

> **Note:** If you have forked this into your own repository, be sure to
> modify the `DownloadString` parameter to the URL of your own fork.

To update later on, just run that command again.

### Add custom commands without creating a new fork

If `.\extra.ps1` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don't want to commit to a public repository.

My `.\extra.ps1` looks something like this:

```posh
# Hg credentials
# Not in the repository, to prevent people from accidentally committing under my name
Set-Environment "EMAIL" "Jeff Strauss <jeff@aranasoft.com>"

# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
Set-Environment "GIT_AUTHOR_NAME" "Jeff Strauss","User"
Set-Environment "GIT_COMMITTER_NAME" $env:GIT_AUTHOR_NAME
git config --global user.name $env:GIT_AUTHOR_NAME
Set-Environment "GIT_AUTHOR_EMAIL" "jeff@aranasoft.com"
Set-Environment "GIT_COMMITTER_EMAIL" $env:GIT_AUTHOR_EMAIL
git config --global user.email $env:GIT_AUTHOR_EMAIL
```

Extras is designed to augment the existing settings and configuration. You could also use `./extra.ps1` to override settings, functions and aliases from my dotfiles repository, but it is probably better to [fork this repository](#forking-your-own-version).

### Sensible Windows defaults

When setting up a new Windows PC, you may want to set some Windows defaults and features, such as showing hidden files in Windows Explorer and installing IIS. This will also set your machine name and full user name, so you may want to modify this file before executing.

```post
.\windows.ps1
```

If you are not going to tie your Windows installation to a Microsoft
Live Account, then be sure to uncomment the lines 19 to 24 in this file
and set the appropriate `$userFullName` variable before running.

### Install dependencies and packages

When setting up a new Windows box, you may want to install some common packages, utilities, and dependencies. These could include Node.js packages via [NPM](https://www.npmjs.org), [Chocolatey](http://chocolatey.org/) packages, Windows Features and Tools via [Web Platform Installer](https://www.microsoft.com/web/downloads/platform.aspx), and Visual Studio Extensions from the [Visual Studio Gallery](http://visualstudiogallery.msdn.microsoft.com/).

All of these dependencies can be found near the beginning of this file:

```posh
.\deps.ps1
```

> The scripts will install Chocolatey, node.js, and WebPI if necessary.

> **Visual Studio Extensions**  
> Extensions will be installed into your most current version of Visual
> Studio. You can also install additional plugins at any time via
> `Install-VSExtension $url`. The URL can be found on the Gallery; it is
> the extension's `Download` link URL.

## Forking your own version

This repository is built around how I use Windows, which is predominantly in a VM hosted on OSX. As such, things like VNC, FileZilla, or Skype are not installed, as they are available to me on the OS X side, installed by my [OSX dotfiles](https://github.com/jstrauss/dotfiles). If you are using Windows as your primary OS, you may want a different configuration that reflects that, and I recommend you [fork this repository](https://github.com/jayharris/dotfiles-windows/fork) from Jay Harris.

If you do fork for your own custom configuration, you will need to touch a few files to reference your own repository, instead of mine.

Within `/setup/install.ps1`, modify the Repository variables.
```posh
$account = "jstrauss"
$repo    = "dotfiles-windows"
$branch  = "master"
```

Within the Windows Defaults file, `/windows.ps1`, modify the Machine
name on the first line.
```posh
(Get-WmiObject Win32_ComputerSystem).Rename("MyMachineName") | Out-Null
```

Finally, be sure to reference your own repository in the git-free installation command.
```bash
iex ((new-object net.webclient).DownloadString('https://raw.github.com/$account/$repo/$branch/setup/install.ps1'))
```

## Feedback

Suggestions/improvements are
[welcome and encouraged](https://github.com/jstrauss/dotfiles-windows/issues)!

## Author

| [![twitter/jeffreystrauss](https://s.gravatar.com/avatar/b06d474fb0c5bb9d62fee08782c75d14?s=70)](http://twitter.com/jeffreystrauss "Follow @jeffreystrauss on Twitter") |
|---|
| [Jeff Strauss](http://twitter.com/jeffreystrauss/) |

## Thanks to…

* @[Mathias Bynens](http://mathiasbynens.be/) for his [OSX dotfiles](http://mths.be/dotfiles), and @[Jay Harris](http://github.com/jayharris) from whose repository this repo is forked.
