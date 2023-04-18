# Installing Vagrant on Ubuntu 22.04 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=9iNBgqvWcok

## Transcript

Here we have a fresh install of Ubuntu 22.04.
```
werekraken@ubuntu:~$ cat /etc/lsb-release
...
```

Our first step is to ensure that the environment is up-to-date.
```
werekraken@ubuntu:~$ sudo apt-get update
...
werekraken@ubuntu:~$ sudo apt-get upgrade
...
```

It is. Let's install vagrant and VirtualBox.
```
werekraken@ubuntu:~$ sudo apt-get install virtualbox vagrant
...
```

VirtualBox is a well-known, cross-platform hypervisor and provides a virtualization platform upon which vagrant can run machines.

vagrant calls the virtualization platforms it can use providers.

VirtualBox happens to be vagrant's default provider making it arguably the easiest way to get started.

vagrant supports several other providers, either natively or through installable plugins.

Time for some basic validation. And the installation looks good.
```
werekraken@ubuntu:~$ vboxmanage --version
...
werekraken@ubuntu:~$ vagrant --version
...
```
