# Accessing the Console (or GUI) via Vagrantfile [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=NmBaUkhmOzI

## Resources

* 🧱 [Materials..4.3.0](../04.Scripts.03..The.Single.Command.Principle/Materials..4.3.0) (0:00 --> 0:18)
* 🧱 [Materials..5.2.0](../05.Graphical.02..Accessing.the.Console.or.GUI.via.Vagrantfile/Materials..5.2.0) (0:25 --> 1:02)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

Last time, we looked at using VirtualBox Manager to access the console of a vagrant managed machine. 

If instead you need frequent access to the console or GUI, it can be helpful to instantiate a console window whenever the machine is brought up. Let's open our Vagrantfile and set `gui` to `true` for our VirtualBox provider.

```
werekraken@ubuntu:~/demo$ vi Vagrantfile
...
   config.vm.provider "virtualbox" do |v|
...
+    v.gui = true
   end
...
```
Now whenever we bring our machine up, a console window is simultaneously created.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```

Our machine is now booted, but vagrant is still configuring the environment--let's let it finish.

`vagrant up` is nearly done. And let's login.

Time to clean up.
```
werekraken@ubuntu:~/demo$ vagrant destroy -f
...
```

The console window is automatically closed out during destruction.
