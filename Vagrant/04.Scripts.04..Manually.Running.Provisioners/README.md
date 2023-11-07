# Manually Running Provisioners [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=O-Dda0wFg5I

## Resources

* 🧱 [Materials..4.3.0](../04.Scripts.03..The.Single.Command.Principle/Materials..4.3.0) (0:00 --> 1:49)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

Let's bring up our machine.
```
werekraken@ubuntu:~/demo$ vagrant up
...
```

One of vagrant's strongest features is that it provides a clean, well-known starting environment. As we've seen, provisioners can be used to enhance these initial environments by formalizing customizations.

However, some environments are complex to setup from scratch; some changes require many incremental builds or tests. We want vagrant to assist our work--not make it slow or tedious. Therefore, there are times when it becomes advantageous to manually run or rerun provisioners.

`vagrant provision` meets our needs here. We can see that our provisioner just ran and asked yum to install git once again. It's already installed, so yum has nothing to do.
```
werekraken@ubuntu:~/demo$ vagrant provision
...
```

`vagrant provision` can be a real time-saver when developing provisioners themselves--especially substantial ones which usually require many incremental tests.

Structuring provisioners such that they reset each key part of a complex environment, to a known state, can avoid the need to repeat slow initial setups. A declarative configuration tool like puppet might have an advantage over shell provisioners here.

Another option is to provide the formalization in another layer. I constantly use mock to build rpms from inside a vagrant environment. I've also run docker inside a vagrant managed machine to provide structure to certain tasks. An optimal solution all depends on the particulars of the use-case.

Let's clean up.
```
werekraken@ubuntu:~/demo$ vagrant destroy -f
...
```
