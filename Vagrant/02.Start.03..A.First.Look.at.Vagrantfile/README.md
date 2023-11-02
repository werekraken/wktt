# A First Look at Vagrantfile [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=KEGtKEmSBBk

## Resources

* 🧱 [Materials..2.1.0](../02.Start.01..Your.First.Vagrant.Managed.Machine/Materials..2.1.0) (0:00 --> 0:24)
* 🧱 [Materials..2.3.0](../02.Start.03..A.First.Look.at.Vagrantfile/Materials..2.3.0) (0:24 --> 0:49)
* 🧱 [Materials..2.3.1](../02.Start.03..A.First.Look.at.Vagrantfile/Materials..2.3.1) (1:00 --> 1:37)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

We're back in our demo directory with our centos/7 Vagrantfile.
```
werekraken@ubuntu:~/demo$ ls
...
```

The Vagrantfile produced by `vagrant init` comes with a lot of comments. I personally don't like to keep these around and prefer to avoid adding clutter of this sort to source control.

I'm going to remove the comments, but feel free to skip or delay this step to take a peek at them.
```
werekraken@ubuntu:~/demo$ sed -i 's/ *#.*//;/^$/d' Vagrantfile
```

Let's take a look at our remaining Vagrantfile. It's pretty simple ruby code at the moment--little more than setting the box to `centos/7`. And we supplied that as an argument to `vagrant init` last time.
```
werekraken@ubuntu:~/demo$ cat Vagrantfile
...
```

Let's make some edits. I'm going to install vim to do so, but feel free to use any editor you like.
```
werekraken@ubuntu:~/demo$ sudo apt-get install vim
...
```

Let's add some additional cpu and memory resources. And save that.
```
werekraken@ubuntu:~/demo$ vi Vagrantfile
...
+  config.vm.provider "virtualbox" do |v|
+    v.cpus = 2
+    v.memory = 4096
+  end
...
```

Start our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```

Login.
```
werekraken@ubuntu:~/demo$ vagrant ssh
```

We can see our cpu count matches what we set.
```
[vagrant@localhost ~]$ getconf _NPROCESSORS_CONF
...
```

As does our memory--more or less.
```
[vagrant@localhost ~]$ free -m
...
```

We can get a more accurate value with a less common command. The total online memory exactly matches the value we set in Vagrantfile.
```
[vagrant@localhost ~]$ lsmem
...
```

Time to clean up.
```
[vagrant@localhost ~]$ logout
werekraken@ubuntu:~/demo$ vagrant destroy
...
```
