# Vagrantfile Precedence [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=5-ILVHnjnHE

## Transcript

We saw previously that our project Vagrantfile can override settings found in the box Vagrantfile. We overrode the default rsync synced folder and made a VirtualBox synced folder, configured with the same paths, in its place.

This was possible because settings configured in the project Vagrantfile have higher precedence than those in the box Vagrantfile.

Last time, we introduced a third Vagrantfile: the one found in your vagrant home directory. I mentioned that settings in this file apply to all the projects of a user.

The topic of Vagrantfile precedence is increasing in complexity as we go. Thankfully, the Vagrantfile page found in the vagrant documentation includes a comprehensive overview of this topic.

We can see here that the box Vagrantfile is loaded first and, therefore, has the lowest precedence. The vagrant home Vagrantfile is next, followed by the project Vagrantfile.

> <br>
> https://developer.hashicorp.com/vagrant/docs/vagrantfile
> <br><br>

There are additional precedence concerns in multimachine environments or when overriding non-provider specific configuration from within a provider block--these are out-of-scope for now.

Last time, we used our vagrant home Vagrantfile to skip guest additions installation by default.

Let's restore our VirtualBox synced folder using only our project Vagrantfile. We'll uncomment the kernel upgrade and VirtualBox synced folder lines. Then set `vbguest.auto_update` to `true`.
```
werekraken@ubuntu:~/demo$ vi Vagrantfile
...
-#  config.vbguest.installer_options = { allow_kernel_upgrade: true }
-#  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
+  config.vbguest.auto_update = true
+  config.vbguest.installer_options = { allow_kernel_upgrade: true }
+  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
...
```

Based on what we read in the documentation about precedence, the `vbguest.auto_update = true` in our project Vagrantfile should override the `false` value in our vagrant home Vagrantfile.

Let's bring up our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```
And login. We can see the VirtualBox kmods are loaded and the /vagrant directory is of type `vboxsf`--this is indeed a VirtualBox synced folder.
```
werekraken@ubuntu:~/demo$ vagrant ssh
[vagrant@localhost ~]$ lsmod | grep ^vbox
...
[vagrant@localhost ~]$ mount | grep vagrant
...
```
Time to clean up.
```
[vagrant@localhost ~]$ logout
werekraken@ubuntu:~/demo$ vagrant destroy
...
```
Feel free to revert the changes made last time to your vagrant home Vagrantfile now--if you so choose. Doing so will restore the vagrant-vbguest default of automatic installation of guest additions.
