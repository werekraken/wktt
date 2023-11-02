# Customizing Environments with Provisioners [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=i8eA5B6XGRY

## Resources

* 🧱 [Materials..3.7.0](../03.More.07..Vagrantfile.Precedence/Materials..3.7.0) (0:00 --> 1:45)
* 🧱 [Materials..4.1.0](../04.Scripts.01..Customizing.Environments.with.Provisioners/Materials..4.1.0) (2:03 --> 2:43)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

As we've seen, `vagrant up` can create a new machine from a boxed environment in about a minute--which is already amazing.

However, many projects have additional environmental requirements. We want to avoid running a bunch of setup commands every time we create a new environment.

Likewise, building, managing, and maintaining one or more custom boxes for each project, or even project class, would quickly become burdensome.

Thankfully, vagrant supports shell scripts, puppet manifests, ansible playbooks, and more as provisioners. Provisioners let you customize the environment to meet the needs of your project--install dependencies, modify configuration, start a service or two, whatever you need.

The best part is that provisioners run "on the first `vagrant up` that creates the environment"--no additional commands needed.

> <br>
> https://www.vagrantup.com/docs/provisioning
> <br><br>

Leveraging provisioners to customize our environments is highly useful, so let's dig in with a shell script example.

When provisioning requirements for a project are simple, it's clean and easy to satisfy them all in a single script named `provisioner.sh`.

As provisioning requirements increase in complexity, `provisioner.sh` can be split into smaller scripts and organized in a provisioners directory or tree.

One common need for my projects is git. Perhaps to clone a requirement, generate a version string using `git describe`, or even automatically import and commit upstream code--particularly that found in source rpms.

Let's make a simple script which installs git.
```
werekraken@ubuntu:~/demo$ vi provisioner.sh
+#!/bin/bash
+
+set -e
+
+yum install -y \
+  git
```
Add it to our machine definition as a shell provisioner.
```
werekraken@ubuntu:~/demo$ vi Vagrantfile
...
+  config.vm.provision "shell", path: "provisioner.sh"
...
```
And bring up our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```

Let's validate our git installation. This time we'll pass our command into the vm using `vagrant ssh -c`.
```
werekraken@ubuntu:~/demo$ vagrant ssh -c 'git --version'
...
```

Let's clean up. We'll run `vagrant destroy -f` to force destruction without being prompted for confirmation.
```
werekraken@ubuntu:~/demo$ vagrant destroy -f
...
```
