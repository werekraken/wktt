# Augmenting Vagrant with Scripts [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=1OgkcwSVt0A

## Resources

* 🧱 [Materials..4.1.0](../04.Scripts.01..Customizing.Environments.with.Provisioners/Materials..4.1.0)
* 🧱 [Materials..4.2.0](../04.Scripts.02..Augmenting.Vagrant.with.Scripts/Materials..4.2.0)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

With our synced folder setup, we can easily pass files into and out of our machine. Scripts and code can be passed in; build results and artifacts can be passed out.

Let's look at a shell script example which demonstrates an awesome pattern to use with vagrant.

My projects commonly include `build.sh`: a shell script which is run inside a vagrant managed machine to build the project.

Sometimes my projects have `test.sh` to run tests or `prep.sh` to prepare packed source code. Composing the specific commands needed for common project actions into familiarly named scripts can save a lot of mental bandwidth when jumping between projects.

`build.sh` is different than a provisioner. Provisioners usually run once and help setup the environment. `build.sh` may be called once, many times, or not at all. It depends on you're current use-case.

Let's create a simple `build.sh`.
```
werekraken@ubuntu:~/demo$ vi build.sh
+#!/bin/bash
+
+set -e
+
+[[ -f /vagrant/Vagrantfile ]]
+
+echo -n building...
+sleep 1
+echo done
```
Since we're using a VirtualBox synced folder, marking the script as executable will affect both our internal and external environments. Usually, a build script intended for a vagrant environment shouldn't be run in a baremetal environment. Therefore, I like to safeguard against such a case.

My favorite way is to have the script simply bail out, first thing, if /vagrant/Vagrantfile doesn't exist. This allows the synced `build.sh` to be used directly in our vagrant managed machine.

Another option is to copy `build.sh` to a non-synced internal path, then mark it executable. One drawback of this second approach is that if you make edits to the build script, you have to copy and mark it again.

Let's use the Vagrantfile safeguard here.

Peculiarly, our demo project has no formal essence--there's nothing to build, so we'll use sleep to simulate the task.

Let's save that.

And set `build.sh` executable now.
```
werekraken@ubuntu:~/demo$ chmod +x build.sh
```

Bring up our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```

And run `build.sh`.
```
werekraken@ubuntu:~/demo$ vagrant ssh -c '/vagrant/build.sh'
...
```
There it goes.

Let's clean up.
```
werekraken@ubuntu:~/demo$ vagrant destroy -f
...
```
