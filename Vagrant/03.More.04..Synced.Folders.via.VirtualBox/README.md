# Synced Folders via VirtualBox [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=VpDfLxl5NV0

## Resources

* 🧱 [Materials..3.3.0](../03.More.03..VirtualBox.Guest.Additions/Materials..3.3.0)
* 🧱 [Materials..3.4.0](../03.More.04..Synced.Folders.via.VirtualBox/Materials..3.4.0)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

Last time, we setup the vagrant-vbguest plugin to automate installation of VirtualBox guest additions. Now, we're ready to add a VirtualBox synced folder.

Let's open our Vagrantfile and add one. We'll use the same paths as the rsync synced folder configured in the box Vagrantfile, which we saw previously. We'll set the type to `virtualbox` here though. This is a safe pattern and will simply override the existing rsync synced folder.
```
werekraken@ubuntu:~/demo$ vi Vagrantfile
...
+  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
...
```
Let's create an external file.
```
werekraken@ubuntu:~/demo$ touch external
werekraken@ubuntu:~/demo$ ls
...
```
And bring up our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
werekraken@ubuntu:~/demo$ vagrant ssh
...
```
We can see that the file exists in /vagrant.
```
[vagrant@localhost ~]$ ls /vagrant/
...
```
Let's modify it from outside.
```
[vagrant@localhost ~]$ logout
werekraken@ubuntu:~/demo$ echo contents > external 
werekraken@ubuntu:~/demo$ vagrant ssh
...
```
This time the modification is present inside the vm without any extra steps.
```
[vagrant@localhost ~]$ cat /vagrant/external 
...
```
Let's make an internal file.
```
[vagrant@localhost ~]$ touch /vagrant/internal
[vagrant@localhost ~]$ ls /vagrant/
...
[vagrant@localhost ~]$ logout
```
This file is present on the outside without any extra steps.
```
werekraken@ubuntu:~/demo$ ls
...
```
VirtualBox synced folders require a bit more setup, but are extremely useful. Let's clean up.
```
werekraken@ubuntu:~/demo$ vagrant destroy
...
werekraken@ubuntu:~/demo$ rm external internal
werekraken@ubuntu:~/demo$ ls
...
```
