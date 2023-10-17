# Disabling vagrant-vbguest [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=QtPoqLdG7do

## Transcript

When installed, the vagrant-vbguest plugin will attempt to install VirtualBox guest additions into any environment in which they are absent. While this is generally useful, there are times when you simply don't need, or even actively don't want, guest additions.

Skipping guest additions can save you a lot of time for certain use cases and can bypass a bad exit from `vagrant up` in others. It's good to know how to disable this feature when needed.

Let's edit our Vagrantfile. We'll comment out our VirtualBox synced folder and allow kernel upgrade lines. And finally, set `vbguest.auto_update` to `false`.
```
werekraken@ubuntu:~/demo$ vi Vagrantfile
...
+  config.vbguest.auto_update = false
-  config.vbguest.installer_options = { allow_kernel_upgrade: true }
-  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
+#  config.vbguest.installer_options = { allow_kernel_upgrade: true }
+#  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
...
```
Let's bring our machine up.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```
Login and we can see no VirtualBox kmods are loaded.
```
werekraken@ubuntu:~/demo$ vagrant ssh
[vagrant@localhost ~]$ lsmod | grep ^vbox
[vagrant@localhost ~]$ 
```
Time to clean up.
```
[vagrant@localhost ~]$ logout
werekraken@ubuntu:~/demo$ vagrant destroy
...
```
