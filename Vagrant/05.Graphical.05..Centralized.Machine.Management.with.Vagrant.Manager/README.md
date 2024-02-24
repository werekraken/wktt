# Centralized Machine Management with Vagrant Manager [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=Bt0CpB1zGc0

## Resources

* 🧱 [Materials..5.2.1](../05.Graphical.02..Accessing.the.Console.or.GUI.via.Vagrantfile/Materials..5.2.1) (0:00 --> 5:08)
* 🗨 [Subtitles](subtitles.srt)

## Transcript

Here we have our new install of Vagrant Manager: a GUI tool providing centralized management of vagrant machines.
```
werekraken@macos:~$ ls /usr/local/Caskroom/vagrant-manager/
...
```

Vagrant Manager is only available on macOS and Windows at present. So, we're back on our macOS 12.6.3 baremetal environment.
```
werekraken@macos:~$ sw_vers
...
```

I've copied our demo project over from my Ubuntu environment.
```
werekraken@macos:~$ cd demo/
werekraken@macos:~/demo$ 
```

And I've installed vagrant-vbguest in my macOS environment.
```
werekraken@macos:~/demo$ vagrant plugin list
...
```

Finally, I created and destroyed this vagrant managed machine a few minutes ago. This ensures that the one time events and operations we've already seen, like box download, have been triggered.
```
werekraken@macos:~/demo$ echo | cat .vagrant/machines/default/virtualbox/action_set_name -
...
```
At this point, my macOS vagrant setup should be in the same essential state as my Ubuntu vagrant setup was when we last saw it.

Let's open Vagrant Manager. Currently, it doesn't show any machines. Let's refresh--still nothing.

This is an important take away: without additional configuration, Vagrant Manager ignores machines in the "not created" state.
```
werekraken@macos:~/demo$ vagrant status
...
```

Let's bring up our machine.
```
werekraken@macos:~/demo$ vagrant up
...
```

Time to refresh again.

Now we can see a menu entry for our project in Vagrant Manager. Hover over the entry and a menu of options will be presented.

With a single click on "SSH", Vagrant Manager will open a terminal, change to the project directory, and run `vagrant ssh`. One click and we're logged in to our vm.

By selecting "Open in Terminal", Vagrant Manager will open a terminal and change to the project directory--no automated `vagrant ssh` this time. However, you'll land in the project directory with the full command line, including `vagrant ssh`, at your disposal.

Let's select "SSH" to login to our machine.

Now we have a new terminal window sitting at the prompt of our internal environment. We can run any commands available in our vm like normal.
```
[vagrant@localhost ~]$ cat /etc/centos-release
...
```

When ready, we can log out. And we end up at the prompt of our external environment. This is the same place where "Open in Terminal" would have taken us directly.

Here we can run any commands available to our baremetal environment like normal. Surprise, surprise, our machine is running.
```
werekraken@macos:~/demo$ vagrant status
...
```

Close out of the terminal window using standard methods when ready.

As we saw a moment ago, Vagrant Manager won't present machines in the "not created" state. If we destroy this machine, it will be removed from the menu.

If you want specific machines present in Vagrant Manager even when "not created", you can bookmark them. Let's do so for demo now.

And then destroy from Vagrant Manager.

Click confirm to move forward with the destruction.

A task window opens and runs `vagrant destroy` on our behalf.

Let's close out of that.

We can see that Vagrant Manager has an entry for demo despite the fact that it's in the "not created" state.
```
werekraken@macos:~/demo$ vagrant status
...
```

Now we can bring up our machine using Vagrant Manager.

A task window opens and runs `vagrant up` for us.

Vagrant Manager exposes many useful vagrant actions in clickable form. If you're most comfortable using a GUI environment, this tool may become a significant part of your vagrant workflow.

My main use case for Vagrant Manager is to quickly locate abandoned vms. When priorities shift suddenly, it's all too easy to leave machines behind, needlessly consuming finite resources. For me, Vagrant Manager simplifies reclaiming cpu, memory, and storage resources currently tied up by discarded vagrant machines.

Let's clean up.
