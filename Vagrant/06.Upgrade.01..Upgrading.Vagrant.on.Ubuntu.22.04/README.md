# Upgrading Vagrant on Ubuntu 22.04 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=tRqjJPvRCS8

## Resources

* 🗨 [Subtitles](subtitles.srt)

## Transcript

We're back on our Ubuntu 22.04 baremetal environment.
```
werekraken@ubuntu:~$ cat /etc/lsb-release
...
```

Let's make sure it's up-to-date.
```
werekraken@ubuntu:~$ sudo apt-get update
...
werekraken@ubuntu:~$ sudo apt-get upgrade
...
```
It is. And this includes the vagrant and VirtualBox packages we previously installed--we simply used the native distro packages included with Ubuntu 22.04.

This is the installation pattern I would commonly use and it's enough for most use cases.

If we just want to ensure that our environment has the latest security patches, we're already done. We're relying on the Ubuntu project for a whole operating-systems-worth of security updates--what's a few more packages?

That said, there may be times when it becomes worthwhile to single out vagrant and install the newest available version--say, when you need a specific fix or feature found in newer vagrant builds.

Let's look at the upgrade process now using the official vagrant installation documentation for Ubuntu as guidance. Our goal here is to upgrade vagrant to the latest HashiCorp provided `.deb` suitable for Ubuntu 22.04.

> <br>
> https://developer.hashicorp.com/vagrant/install
> <br><br>

vagrant itself is created and maintained by HashiCorp. Trusting HashiCorp packages when already using vagrant seems sensible.

Let's download the `.gpg` key found on this page. However, let's write it to a file in our home directory for now--we want a bit more verification before writing it to a restricted path.
```
werekraken@ubuntu:~$ wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o hashicorp-archive-keyring.gpg
...
```

Over on the security page included in HashiCorp's trust center, we can find the fingerprint for the `.gpg` key used for signing linux packages, including `.deb`s.

> <br>
> https://www.hashicorp.com/trust/security
> <br><br>

For basic validation of an asset securely downloaded from a trusted domain--such as this--I'm comfortable with a simple visual comparison. I generally compare the first and last 4-6 characters, then check one or two random spots in the middle. Compare the fingerprints programmatically as you see fit.
```
werekraken@ubuntu:~$ gpg --show-keys hashicorp-archive-keyring.gpg
...
```

This download looks good to me. And now I'll move it into place.
```
werekraken@ubuntu:~$ sudo mv -i hashicorp-archive-keyring.gpg /usr/share/keyrings/
```

Next, we need to add the HashiCorp package repository to our sources lists. To do so, I'm going copy and paste the command from the install doc verbatim.

It's worth noting that this one-liner contains a command substitution. Be sure you understand each component of a command before running it.
```
werekraken@ubuntu:~$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
...
```

With the HashiCorp package source configured, we again need to update our indexes of available packages.
```
werekraken@ubuntu:~$ sudo apt-get update
...
```

Now vagrant should have an upgrade candidate--let's install it.
```
werekraken@ubuntu:~$ sudo apt-get upgrade
...
```

To keep things tidy, let's clean up the stale dependencies which were pulled in with our previous vagrant installation.
```
werekraken@ubuntu:~$ sudo apt-get autoremove
...
```

Time for basic validation. The upgrade looks good--at least on the surface.
```
werekraken@ubuntu:~$ vagrant --version
...
```

However, there is a problem caused by this upgrade and listing our plugins will expose it.
```
werekraken@ubuntu:~$ vagrant plugin list
...
```

In this case, reinstalling our plugins to pull in suitable versions of dependencies is the correct course of action.
```
werekraken@ubuntu:~$ vagrant plugin expunge --reinstall
...
```

Now listing, and more importantly using, our plugins will work as expected.
```
werekraken@ubuntu:~$ vagrant plugin list
...
```
And we're done.
