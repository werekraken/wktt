# Upgrading Vagrant on macOS 12 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=0PKT7xBZiXo

## Resources

* 🗨 [Subtitles](subtitles.srt)

## Transcript

We're back on our macOS 12 baremetal environment.
```
werekraken@macos:~$ sw_vers
...
```

Let's make sure the basic system is up-to-date.
```
werekraken@macos:~$ softwareupdate --list
...
```
It is.

To upgrade vagrant and VirtualBox, we simply run the same subcommands we used previously to check if brew managed installs were up-to-date.
```
werekraken@macos:~$ brew update
...
werekraken@macos:~$ brew upgrade
...
```
There it goes.

Time for some basic validation. And the upgrades look good.
```
werekraken@macos:~$ VBoxManage --version
...
werekraken@macos:~$ vagrant --version
...
```
