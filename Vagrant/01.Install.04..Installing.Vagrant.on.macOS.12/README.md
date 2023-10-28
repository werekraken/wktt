# Installing Vagrant on macOS 12 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=XFLLaApEV40

## Resources

🗨 [Subtitles](subtitles.srt)

## Transcript

Here we have macOS 12.6.3 with Homebrew installed.
```
werekraken@mac:~$ sw_vers
...
werekraken@mac:~$ brew --version
...
```

First, we want to ensure that our environment is up-to-date.
```
werekraken@mac:~$ softwareupdate --list
...
```
The basic environment is.

Let's check Homebrew.
```
werekraken@mac:~$ brew update
...
werekraken@mac:~$ brew upgrade
...
```
brew managed installs are up-to-date too.

Let's install vagrant and VirtualBox.
```
werekraken@mac:~$ brew install virtualbox vagrant
...
```

VirtualBox is a well-known, cross-platform hypervisor and provides a virtualization platform upon which vagrant can run machines.

vagrant calls the virtualization platforms it can use providers.

VirtualBox happens to be vagrant's default provider making it arguably the easiest way to get started.

vagrant supports several other providers, either natively or through installable plugins.

Time for basic validation. And the install looks good.
```
werekraken@mac:~$ VBoxManage --version
...
werekraken@mac:~$ vagrant --version
...
```
