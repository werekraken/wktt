# Installing Homebrew on macOS 12 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=l4-lqExciQM

## Resources

🗨 [Subtitles](subtitles.srt)

## Transcript

Here we have macOS 12.6.3 with the command line developer tools installed.
```
werekraken@mac:~$ sw_vers
...
werekraken@mac:~$ xcode-select --print-path
...
```

First, we want to ensure that our environment is up-to-date.
```
werekraken@mac:~$ softwareupdate --list
...
```
The basic environment is.

Let's install Homebrew, which is quite accurately described as "The Missing Package Manager for macOS."

The simple installation instructions over at https://brew.sh suggest running bash on the output of a curl to a well-known github domain.

Even though I have reasonable confidence that the code and platforms involved are legitimate, I won't use this. First, the download isn't validated. Second, there isn't a reliable way to audit what actually ran.

Instead, I'll clone the Homebrew install project--the git checkout process will both ensure the integrity of install.sh and place it on-disk, permitting future examination if desired.
```
werekraken@mac:~$ git clone https://github.com/Homebrew/install
...
werekraken@mac:~$ cd install/
werekraken@mac:~/install$ 
```

And now I'll run it.
```
werekraken@mac:~/install$ ./install.sh
...
```

Homebrew makes it easy to install many tools not included with macOS. A thriving community which maintains thousands of package definitions covers most common needs.

Package definitions come in two forms, providing quite a bit of flexibility. A formula builds and installs an upstream source project. A cask installs a project's pre-built application binaries. Nowadays, both types are accessible using `brew install`.

Homebrew simply makes life on macOS easier and is well worth the install.

Let's check our installation. And looks good.
```
werekraken@mac:~/install$ brew --version
...
```
