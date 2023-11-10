# Accessing the Console (or GUI) via VirtualBox Manager [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=fyU_pb-KG2g

## Resources

* 🧱 [Materials..4.3.0](../04.Scripts.03..The.Single.Command.Principle/Materials..4.3.0) (0:00 --> 1:16)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

Let's bring up our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```

Another highly desirable skill is to be able to access the console of vagrant managed machines. This is especially useful when doing low-level work--say, troubleshooting boot issues or looking into a softlockup.

Alternatively, if your vagrant managed machine is running a GUI, you can access it using these same methods. I've used the GUI of a vagrant managed machine to access legacy ipmi web portals requiring ancient java components. GUI use cases for vagrant definitely exist.

Similarly to shutdown commands, the native method for console access provided by your hypervisor should still work.

In the case of VirtualBox, we can simply open the VirtualBox Manager, select the appropriate machine, and select show to bring up the console or GUI.
```
werekraken@ubuntu:~/demo$ virtualbox
...
```
This method is especially useful for machines that are already running. Let's clean up.
```
werekraken@ubuntu:~/demo$ vagrant destroy -f
...
```
