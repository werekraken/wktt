# Synced Folders via Rsync [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=I6tDOjEyG-Q

## Resources

* 🧱 [Materials..2.3.1](../02.Start.03..A.First.Look.at.Vagrantfile/Materials..2.3.1) (0:00 --> 3:27)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

We previously learned that `vagrant halt` can be used to persist the internal storage of vagrant managed machines. However, often you will want to reclaim these storage resources when stepping away from a project.

We also learned that `vagrant up` provides us with a solid starting environment. Generally, the next step is customizing that environment by deploying code and config. Frequently, this step includes files sourced from our project root.

vagrant just wouldn't be complete without a way to copy files into and out of machines. Thankfully, it provides a mechanism for this: synced folders.

There are several types of synced folders supported by vagrant. Let's begin with the default synced folder type shipped with our `centos/7` box, rsync.

Let's create a file in our project root.
```
werekraken@ubuntu:~/demo$ touch external
werekraken@ubuntu:~/demo$ ls
...
```
And bring our machine up.
```
werekraken@ubuntu:~/demo$ vagrant up
...
werekraken@ubuntu:~/demo$ vagrant ssh
...
```
We can see the file exists inside our vm too, in /vagrant.
```
[vagrant@localhost ~]$ ls /vagrant/
...
```
Let's log out and modify the file by adding some contents.
```
[vagrant@localhost ~]$ logout
werekraken@ubuntu:~/demo$ echo contents > external 
werekraken@ubuntu:~/demo$ cat external 
...
werekraken@ubuntu:~/demo$ vagrant ssh
...
```
The modification isn't present inside the vm.
```
[vagrant@localhost ~]$ cat /vagrant/external 
[vagrant@localhost ~]$ 
```
In the case of rsync synced folders, we need to run `vagrant rsync` to transfer the change in.
```
[vagrant@localhost ~]$ logout
werekraken@ubuntu:~/demo$ vagrant rsync
...
werekraken@ubuntu:~/demo$ vagrant ssh
...
```
And now we can see our modification.
```
[vagrant@localhost ~]$ cat /vagrant/external
...
```
Next, let's create a file, inside the vm, in the /vagrant directory.
```
[vagrant@localhost ~]$ touch /vagrant/internal
[vagrant@localhost ~]$ ls /vagrant/
...
[vagrant@localhost ~]$ logout
```
This file isn't present in our project root.
```
werekraken@ubuntu:~/demo$ ls
...
```
Let's see what happens if we run `vagrant rsync`.
```
werekraken@ubuntu:~/demo$ vagrant rsync
...
werekraken@ubuntu:~/demo$ vagrant ssh
...
```
This is an important take away. `vagrant rsync` copies files into the vm from outside, not from the inside out. And is destructive by default.
```
[vagrant@localhost ~]$ ls /vagrant/
...
```
Let's create our internal file again.
```
[vagrant@localhost ~]$ touch /vagrant/internal
[vagrant@localhost ~]$ ls /vagrant/
...
[vagrant@localhost ~]$ logout
```
We can leverage `rsync`'s `-e` option to set the remote shell command to `vagrant ssh`. No hostname is needed preceeding the colon since `vagrant ssh` will already access our vagrant managed machine.
```
werekraken@ubuntu:~/demo$ rsync -av -e 'vagrant ssh --' :/vagrant/ .
...
```
Now the internal file is present in our external project root and will persist, even if the machine is destroyed.
```
werekraken@ubuntu:~/demo$ ls
...
```
Another cool property of using `rsync -e` is that it can copy files with arbitrary paths in or out. `vagrant rsync` instead operates on pre-configured paths--it takes less typing, but is less flexible for on-the-fly work.

Let's clean up--including our external and internal files.
```
werekraken@ubuntu:~/demo$ vagrant destroy
...
werekraken@ubuntu:~/demo$ rm external internal
werekraken@ubuntu:~/demo$ ls
...
```
