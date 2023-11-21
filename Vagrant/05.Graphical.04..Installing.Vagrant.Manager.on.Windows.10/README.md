# Installing Vagrant Manager on Windows 10 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=YttcLQynjEE

## Resources

* 🗨 [Subtitles](subtitles.srt)

## Transcript

Another interesting GUI tool, especially when using vagrant frequently, is Vagrant Manager.

Per the project README, "Vagrant Manager is a Windows status bar menu app that lets you manage all of your vagrant machines from one central location."

> <br>
> https://github.com/lanayotech/vagrant-manager-windows
> <br><br>

Vagrant Manager is also available for macOS. However, unfortunately, Vagrant Manager isn't available on Linux distros, like Ubuntu, at present.

We're back on our Windows 10 baremetal environment with the PSWindowsUpdate PowerShell module, VirtualBox, and vagrant installed.
```
PS C:\Users\werekraken> cmd /c ver
...
PS C:\Users\werekraken> Import-Module PSWindowsUpdate
PS C:\Users\werekraken> $env:PATH = $env:PATH + ';C:\Program Files\Oracle\VirtualBox'
PS C:\Users\werekraken> VboxManage --version
...
PS C:\Users\werekraken> vagrant --version
...
```

Vagrant Manager requires the `vagrant` command to be in your `$env:PATH`--we just verified that this need is met with our version check.

Next, we want to ensure that our environment is up-to-date.
```
PS C:\Users\werekraken> Get-WindowsUpdate
```
The basic environment is.

If updates are needed, they can be installed with a few extra flags. Be sure to only use the `-AutoReboot` flag if now is a suitable time for a reboot.
```
PS C:\Users\werekraken> Get-WindowsUpdate -AcceptAll -Install -AutoReboot
```

With our system updated, we're ready to install Vagrant Manager. Let's download the Vagrant Manager setup executable from the latest release.

> <br>
> https://github.com/lanayotech/vagrant-manager-windows/releases/tag/1.0.2.2
> <br><br>

```
PS C:\Users\werekraken> Invoke-WebRequest -UseBasicParsing -Uri https://github.com/lanayotech/vagrant-manager-windows/releases/download/1.0.2.2/VagrantManager-1.0.2.2-Setup.exe -OutFile VagrantManager-1.0.2.2-Setup.exe
...
```

Unfortunately, this project doesn't provide us with the means to validate our download--no checksums or similar are included. However, hope is not lost.

Chocolatey is a well-known package manager facilitating automated software installations on Windows. This package manager itself is out-of-scope for now, but that doesn't mean we can harvest some useful information from the project.

> <br>
> https://github.com/chtof/chocolatey-packages/blob/0e28162efe439e7f004176b40f9de08120445994/manual/vagrant-manager/tools/chocolateyinstall.ps1
> <br><br>

The Chocolatey install PowerShell script for Vagrant Manager includes a SHA-256 of the same setup `.exe` we just downloaded. Verifying that our download has the same SHA-256 reduces our chances of unnoticed file corruption or tampering.
```
PS C:\Users\werekraken> Get-FileHash .\VagrantManager-1.0.2.2-Setup.exe
...
```

For basic validation of an asset securely downloaded from a trusted domain--such as this--I'm comfortable with a simple visual comparison. I generally compare the first and last 4-6 characters, then check one or two random spots in the middle. Compare the hashes programmatically as you see fit.

This download looks good to me. Research Vagrant Manager and Chocolatey as needed and move forward if you so choose.

The Chocolatey PowerShell script also gives us the arguments needed to have a silent, promptless install.

Let's install Vagrant Manager by running the setup `.exe` with these arguments.
```
PS C:\Users\werekraken> .\VagrantManager-1.0.2.2-Setup.exe /verysilent /norestart /allusers
```

This will both install and open Vagrant Manager--which can take several seconds.

To access Vagrant Manager once it's running, click the newly introduced "V" icon in the notification area at the right end of the Windows taskbar. Our install looks good.

To finalize initial setup, there's one more step--and we're only prompted the second time we open Vagrant Manager on Windows.

Let's exit and wait for the "V" icon to disappear. Then reopen Vagrant Manager--I'm going to do so via PowerShell, but using the Start menu will work just as well.

On second open, we're immediately met with a Vagrant Manager prompt about automatic updates. I'm going to decline for now, but feel free to accept as you see fit.

And we're done.
