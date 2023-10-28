# The Box Vagrantfile [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=mCQl-lFEn9o

## Resources

🧱 [Materials..3.2.0](../03.More.02..The.Box.Vagrantfile/Materials..3.2.0)
🗨 [Subtitles](subtitles.srt)

## Transcript

Last time, we looked at the default rsync synced folder for our `centos/7` box. So, where did this synced folder come from--where is it configured?

vagrant boxes actually ship with a Vagrantfile containing some box-level default configuration.

Let's take a look at the Vagrantfile that came with the `centos/7` box I'm using, version `2004.01`.
```
werekraken@ubuntu:~/demo$ cat ~/.vagrant.d/boxes/centos-VAGRANTSLASH-7/2004.01/virtualbox/Vagrantfile
...
```
Here we can see the rsync synced folder config mapping our project root to /vagrant. It's as simple as that.
