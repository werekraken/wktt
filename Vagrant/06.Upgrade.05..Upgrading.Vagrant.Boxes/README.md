# Upgrading Vagrant Boxes [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=7zUs8rhzy38

## Resources

* 🗨 [Subtitles](subtitles.srt)

## Transcript

Here we have an Ubuntu 22.04 baremetal environment with an outdated `centos/7` vagrant box.
```
werekraken@ubuntu:~$ cat /etc/lsb-release 
...
werekraken@ubuntu:~$ vagrant box outdated --global
...
```

Let's upgrade it.
```
werekraken@ubuntu:~$ vagrant box update --box centos/7
...
```

Time to verify. We can see that the new version is present, as was desired. However, it may be surprising to find--on first encounter--that the old version is still here too.
```
werekraken@ubuntu:~$ vagrant box outdated --global
...
```
vagrant supports multiple versions of the same box at the same time. They can be installed and used side-by-side.

By default new machines will use the latest installed version of a box. However, by adding version constraints in Vagrantfile new machines can be configured to use an older version.

In most cases older versions aren't needed and removing them frees up precious storage resources. A simple `vagrant box prune` will clean things up nicely.
```
werekraken@ubuntu:~$ vagrant box prune
...
```

Verify again and we can see that the old box is now gone.
```
werekraken@ubuntu:~$ vagrant box outdated --global
...
```
