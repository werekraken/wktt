# Installing Vagrant Manager on macOS 12 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=9vDaDA0UgeY

## Resources

* 🗨 [Subtitles](subtitles.srt)

## Transcript

Another interesting GUI tool, especially when using vagrant frequently, is Vagrant Manager.

Per the project README, "Vagrant Manager is an OS X status bar menu app that lets you manage all of your vagrant machines from one central location."

> <br>
> https://github.com/lanayotech/vagrant-manager
> <br><br>

We can see at the very top of `README.md` that there's also a Vagrant Manager for Windows. However, unfortunately, Vagrant Manager isn't available on Linux distros, like Ubuntu, at present.

We're back on our macOS 12.6.3 baremetal environment with Homebrew, VirtualBox, and vagrant installed.
```
werekraken@macos:~$ sw_vers
...
werekraken@macos:~$ brew --version
...
werekraken@macos:~$ VBoxManage --version
...
werekraken@macos:~$ vagrant --version
...
```
Vagrant Manager requires the `VBoxManage` and `vagrant` commands to be in your `$PATH`--we just verified that this need is met with our version checks.

Next, we want to ensure that our environment is up-to-date.
```
werekraken@macos:~$ softwareupdate --list
...
```
The basic environment is.

Let's check Homebrew.
```
werekraken@macos:~$ brew update
...
werekraken@macos:~$ brew upgrade
...
```
brew managed installs, including vagrant and VirtualBox, are up-to-date too.

Let's install Vagrant Manager.
```
werekraken@macos:~$ brew install vagrant-manager
...
```

Time to validate our install.

Open Launchpad and select Vagrant Manager. Right away, we're met with one flavor of macOS Gatekeeper prompt.

Per the Gatekeeper documentation, "When a user downloads and opens an app, a plug-in, or an installer package from outside the App Store, Gatekeeper verifies that the software is from an identified developer, is notarized by Apple to be free of known malicious content, and hasn’t been altered."

> <br>
> https://support.apple.com/guide/security/gatekeeper-and-runtime-protection-sec5599b66df/web
> <br><br>

That all sounds great. However, the Apple Developer Program membership required for their services isn't free. And, like many open source projects, Vagrant Manager doesn't meet these standards.

Thankfully, `brew install` will have already programmatically validated our Vagrant Manager download using the SHA-256 included in the cask. Research Vagrant Manager and Homebrew as needed and move forward if you so choose.

```
werekraken@macos:~$ brew cat vagrant-manager | grep -m1 sha256
...
```

To move forward, select "Show in Finder", right click the Vagrant Manager icon, select "Open" from the menu, and click "Open" again on the Gatekeeper prompt.

Doing so will automatically add a security settings exception for Vagrant Manager. Next time we open it, we won't have to repeat this process.

Vagrant Manager itself is now prompting about automatic updates. I'm going to decline for now, but feel free to accept as you see fit.

To access Vagrant Manager now that it's running, click the newly introduced "V" icon in the upper right section of the macOS status bar. Our install looks good.
