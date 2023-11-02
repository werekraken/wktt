# VirtualBox Guest Additions [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=0JcFdpUITBE

## Resources

* 🧱 [Materials..2.3.1](../02.Start.03..A.First.Look.at.Vagrantfile/Materials..2.3.1) (0:00 --> 0:32)
* 🧱 [Materials..3.3.0](../03.More.03..VirtualBox.Guest.Additions/Materials..3.3.0) (0:45 --> 2:24)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

VirtualBox guest additions provide some decidedly advantageous features. Among these is VirtualBox synced folders--a clear step up from rsync synced folders for many vagrant use cases.

Let's install the vagrant-vbguest plugin which will automate installation of VirtualBox guest additions. Conveniently, the needed steps are added to the `vagrant up` process.
```
werekraken@ubuntu:~/demo$ vagrant plugin install vagrant-vbguest
...
```
In this case, I'm going to configure the plugin to upgrade the kernel as needed.

```
werekraken@ubuntu:~/demo$ vi Vagrantfile
...
+  config.vbguest.installer_options = { allow_kernel_upgrade: true }
...
```
Let's bring our machine up.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```
So, why did we need to allow kernel upgrade?

Installation of VirtualBox guest additions includes the building of a handful of kernel modules. One of these kmods facilitates VirtualBox shared folders: the underlying mechanism upon which vagrant's VirtualBox synced folders are built.

Since we want to explore VirtualBox synced folders, we'll need these kmods to build successfully.

The `centos/7` box I'm using, version `2004.01`, contains a CentOS 7.8 environment. However, the contained yum repo config currently points to CentOS 7.9 packages--7.8 has been archived.

We need version matched installations of the kernel and kernel-devel rpms in order to build our kmods.

A CentOS 7.8 kernel and 7.9 kernel-devel won't do. We either need to retrieve kernel-devel from the 7.8 archives, or upgrade the kernel to the CentOS 7.9 version. In this case, the former gives no advantage, and the latter is easier to accomplish--hence, `allow_kernel_upgrade: true`.

Guest additions are now installed. Login and we can see the VirtualBox kmods are loaded.
```
werekraken@ubuntu:~/demo$ vagrant ssh
[vagrant@localhost ~]$ lsmod | grep ^vbox
...
```
Let's clean up.
```
[vagrant@localhost ~]$ logout
werekraken@ubuntu:~/demo$ vagrant destroy
...
```
