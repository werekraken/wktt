# Upgrading Vagrant Plugins [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=YDJm83MldBQ

## Resources

* 🗨 [Subtitles](subtitles.srt)

## Transcript

Here we have an Ubuntu 22.04 baremetal environment with an outdated vagrant-vbguest plugin.
```
werekraken@ubuntu:~$ cat /etc/lsb-release
...
werekraken@ubuntu:~$ vagrant plugin list
...
```

Let's upgrade it.
```
werekraken@ubuntu:~$ vagrant plugin update
...
```

Time to verify. Looks good.
```
werekraken@ubuntu:~$ vagrant plugin list
...
```
