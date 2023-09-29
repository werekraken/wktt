# Your First Vagrant Managed Machine on Windows [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=ipjYKkupVTk

## Transcript

Here we have new installs of vagrant and VirtualBox.
```
PS C:\Users\werekraken> vagrant --version
...
PS C:\Users\werekraken> $env:PATH = $env:PATH + ';C:\Program Files\Oracle\VirtualBox'
PS C:\Users\werekraken> VboxManage --version
...
```

Let's go through the same steps we just saw on Ubuntu--this time using a Windows 10 baremetal environment.
```
PS C:\Users\werekraken> cmd /c ver
...
```
By doing so, we'll get to see just how similar the commands and outputs look, even when run on a dissimilar baremetal environment.

To start using vagrant, we need a Vagrantfile. A Vagrantfile typically lives in a project, often in the project root.

Let's create a directory called demo to serve as our new project root.
```
PS C:\Users\werekraken> mkdir demo
...
PS C:\Users\werekraken> cd demo
PS C:\Users\werekraken\demo> 
```

Next, we need a machine definition. `vagrant init` makes creating a basic definition simple. My baremental environment is Windows, so let's make our vm environment CentOS 7. The format change of the prompt will make it clear in which environment each command is run.
```
PS C:\Users\werekraken\demo> vagrant init centos/7
...
```

We can see a Vagrantfile is now present.
```
PS C:\Users\werekraken\demo> ls
...
```

Let's spin up our machine.
```
PS C:\Users\werekraken\demo> vagrant up
...
```

One helpful feature of `vagrant up` is that it automatically downloads the configured box if absent.

Another option is to use `vagrant box` which let's you directly manage boxes. `vagrant box` includes subcommands such as `add`, `update`, and `remove`.

`vagrant box add` could have been used to download the centos/7 box ahead of `vagrant up`. In this case, we're using the box right away, so there's no advantage to pre-fetching. However, it's an interesting option to keep in mind.

Now that our machine is running, we can access it with `vagrant ssh`.
```
PS C:\Users\werekraken\demo> vagrant ssh
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
...
```

Finally, we use `vagrant destroy` to clean up.
```
PS C:\Users\werekraken\demo> vagrant destroy
...
```
That vm is now gone and the cpu, memory, and storage resources it was consuming have been freed.

So cool.
