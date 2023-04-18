# Installing the Command Line Developer Tools on macOS 12.6.3 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=ovX__bk2sIw

## Transcript

Here we have a fresh install of macOS 12.6.3.
```
werekraken@mac:~$ sw_vers
...
```

First, we want to ensure that our environment is up-to-date.
```
werekraken@mac:~$ softwareupdate --list
...
```
The basic environment is.

Let's install the command line developer tools.
```
werekraken@mac:~$ xcode-select --install
...
```

Click the install button on the gui prompt to move forward. Read the license agreement and click agree if you so choose.

Now the command line developer tools, part of Apple's Xcode IDE, are installing.

The command line developer tools contain many useful executables, including git. In addition to the value it provides directly, git is also needed to install Homebrew and run installs with Homebrew.

git can also be installed via Homebrew, but we need git in order to install Homebrew. This approach isn't going to work--at least not at this stage.

Of course, we can always build git from source. Doing so requires we have the needed build toolchain. An easy way to get that is to install the command line developer tools.

Notice a pattern here--when using macOS, you'll likely want to install the command line developer tools.

Let's validate our install.
```
werekraken@mac:~$ xcode-select --print-path
...
werekraken@mac:~$ pkgutil --file-info /Library/Developer/CommandLineTools | grep 'pkg\|^$'
...
```

And more importantly, let's validate one of the installed executables.
```
werekraken@mac:~$ git --version
...
```
Looks good.
