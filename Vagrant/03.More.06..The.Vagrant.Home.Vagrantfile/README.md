# The Vagrant Home Vagrantfile [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=gLtZtpE7pA8

## Resources

🧱 [Materials..3.5.0](../03.More.05..Disabling.vagrant-vbguest/Materials..3.5.0)
🧱 [Materials..3.6.0](../03.More.06..The.Vagrant.Home.Vagrantfile/Materials..3.6.0)
🗨 [Subtitles](subtitles.srt)

## Transcript

So far, we've configured vagrant by adding settings to our project Vagrantfile. Another option is to apply config to a user-level Vagrantfile found in your vagrant home--by default `~/.vagrant.d/`.

Let's start by deleting the `auto_update` line from our project Vagrantfile.
```
werekraken@ubuntu:~/demo$ vi Vagrantfile
...
-  config.vbguest.auto_update = false
...
```
As we saw previously, if we run `vagrant up` with this config, the vagrant-vbguest plugin will attempt to install guest additions. Let's change the plugin's default behavior for our user to skip guest additions installation.

To do this, we simply create a Vagrantfile in our vagrant home, add the basic config structure, and set `vbguest.auto_update` to `false`--essentially, the same thing as we did in our project Vagrantfile.
```
werekraken@ubuntu:~/demo$ vi ~/.vagrant.d/Vagrantfile
+Vagrant.configure("2") do |config|
+  config.vbguest.auto_update = false
+end
```
Let's bring our machine up.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```
Login and again we can see no VirtualBox kmods are loaded.
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
