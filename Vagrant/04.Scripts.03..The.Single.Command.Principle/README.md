# The Single Command Principle [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=7vmRaDPX-wA

## Resources

* 🧱 [Materials..4.2.0](../04.Scripts.02..Augmenting.Vagrant.with.Scripts/Materials..4.2.0) (0:00 --> 1:35)
* 🧱 [Materials..4.3.0](../04.Scripts.03..The.Single.Command.Principle/Materials..4.3.0) (2:05 --> 2:48)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

As we've seen, vagrant lets us create and manage virtual machine environments using a single, simplified workflow. Last time, we explored codifying common project actions into well-named scripts.

Let's look at another great way we can leverage shell scripts to add convenience and free-up head space.

Years ago, I was introduced to a pattern in which you formalize the most common workflow for a project as a single command. Since then, nearly all of my projects have included this pattern in some form or another.

I needed a name for this pattern and a web search delivered.

In his blog, Wojciech Koszek calls this idea the "Single Command Principle"--as serviceable a name as I've ever heard. While his post focuses on deployment, this concept works just as well for development workflows.

> <br>
> https://koszek.org/single-command-principle/
> <br><br>

My go to implementation for this pattern is `runner.sh`: a shell script entry point run on our baremetal environment to create, make use of, and clean up a vagrant managed machine. `runner.sh` wraps and runs every command needed for our most common workflow--this could include building, testing, deploying, and more.

Let's put together a simple `runner.sh`.
```
werekraken@ubuntu:~/demo$ vi runner.sh
+#!/bin/bash
+
+vagrant up
+vagrant ssh -c 'cd /vagrant && ./build.sh'
+[[ "$RUNNER_VAGRANT_DESTROY" == "false" ]] ||
+  vagrant destroy -f
```

This `runner.sh` can be prepended with `RUNNER_VAGRANT_DESTROY=false` to skip destruction on a given run. Doing so can be a big time saver by skipping subsequent environment creations--especially when changing or troubleshooting workflows. I include this even in the simplest `runner.sh`.

Let's make it executable.
```
werekraken@ubuntu:~/demo$ chmod +x runner.sh
```

And run it.
```
werekraken@ubuntu:~/demo$ ./runner.sh
...
```

We can see that `runner.sh` created our machine, ran the build, and cleaned up. So cool.

To skip destruction, we'd invoke `runner.sh` like this. Feel free to explore this more as you see fit.
```
werekraken@ubuntu:~/demo$ RUNNER_VAGRANT_DESTROY=false ./runner.sh
```
