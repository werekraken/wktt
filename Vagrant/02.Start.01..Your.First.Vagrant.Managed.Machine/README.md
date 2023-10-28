# Your First Vagrant Managed Machine [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=JpI8Rtxo828

## Resources

* 🧱 [Materials..2.1.0](../02.Start.01..Your.First.Vagrant.Managed.Machine/Materials..2.1.0)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

Here we have new installs of vagrant and VirtualBox.
```
werekraken@ubuntu:~$ vagrant --version
...
werekraken@ubuntu:~$ vboxmanage --version
...
```

My baremetal environment happens to be Ubuntu 22.04.
```
werekraken@ubuntu:~$ cat /etc/lsb-release
...
```
However, the commands and outputs should look quite similar when run elsewhere.

To start using vagrant, we need a Vagrantfile. A Vagrantfile typically lives in a project, often in the project root.

Let's create a directory called demo to serve as our new project root.
```
werekraken@ubuntu:~$ mkdir demo
werekraken@ubuntu:~$ cd demo
werekraken@ubuntu:~/demo$ 
```

Next, we need a machine definition. `vagrant init` makes creating a basic definition simple. Since my baremetal environment is Ubuntu, let's make our vm CentOS 7. The format change of the prompt will make it clear in which environment each command is run.
```
werekraken@ubuntu:~/demo$ vagrant init centos/7
...
```

We can see a Vagrantfile is now present.
```
werekraken@ubuntu:~/demo$ ls
...
```

Let's spin up our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```

One helpful feature of `vagrant up` is that it automatically downloads the configured box if absent.

Another option is to use `vagrant box` which let's you directly manage boxes. `vagrant box` includes subcommands such as `add`, `update`, and `remove`.

`vagrant box add` could have been used to download the centos/7 box ahead of `vagrant up`. In this case, we're using the box right away, so there's no advantage to pre-fetching. However, it's an interesting option to keep in mind.

Now that our machine is running, we can access it with `vagrant ssh`.
```
werekraken@ubuntu:~/demo$ vagrant ssh
```

A quick look in /etc/ and we can confirm that this is indeed a CentOS 7 environment.
```
[vagrant@localhost ~]$ cat /etc/centos-release
...
```

Feel free to poke around in this environment more now.

When ready to leave, simply logout. I tend to use control-d to do so.
```
[vagrant@localhost ~]$ logout
```

Finally, we use `vagrant destroy` to clean up.
```
werekraken@ubuntu:~/demo$ vagrant destroy
...
```
That vm is now gone and the cpu, memory, and storage resources it was consuming have been freed.

So cool.
