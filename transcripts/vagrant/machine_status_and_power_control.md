# Machine Status and Power Control [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=sfxot1Nepqg

## Transcript

In the real world, you'll probably have to set a project aside from time-to-time. Sometimes this means devoting your cpu and memory resources to another cause.

The good news is that typical commands like `shutdown`, `halt`, and `poweroff` work as expected when run inside a vagrant managed machine. When you want the machine back up, you simply run `vagrant up` again.

Other times you may want to shutdown or reboot a machine you can't access, rather than destroy it. If you're troubleshooting a kernel panic, developing a config for kdump, testing a newly manipulated initrd, or similar `vagrant halt` will undoubtedly come in handy.

These options point out another skill we need: the ability to find the current state of a machine.

We can use `vagrant status` to see this. Right now, the state is "not created", which makes sense since the last thing we did was `vagrant destroy`.
```
werekraken@ubuntu:~/demo$ vagrant status
...
```

Let's bring up our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```

Now, status shows that it's "running".
```
werekraken@ubuntu:~/demo$ vagrant status
...
```

Let's log in briefly and create a new file.
```
werekraken@ubuntu:~/demo$ vagrant ssh
[vagrant@localhost ~]$ touch file
[vagrant@localhost ~]$ ls
...
[vagrant@localhost ~]$ logout
...
```

Then halt the machine.
```
werekraken@ubuntu:~/demo$ vagrant halt
...
```

Another status check shows that it's in the "poweroff" state.
```
werekraken@ubuntu:~/demo$ vagrant status
...
```

Let's bring our vm back up.
```
werekraken@ubuntu:~/demo$ vagrant up
...
werekraken@ubuntu:~/demo$ vagrant ssh
```

We can see that our file persisted. This is a key difference between `destroy` and `halt`. `destroy` doesn't persist storage that is exclusive to the vm. `halt` doesn't free storage resources consumed by the vm. Both are useful for different cases.
```
[vagrant@localhost ~]$ ls
...
```

Let's clean up.
```
[vagrant@localhost ~]$ logout
...
werekraken@ubuntu:~/demo$ vagrant destroy
...
```

A final `vagrant status` and we see that our state has returned to "not created".
```
werekraken@ubuntu:~/demo$ vagrant status
...
```
