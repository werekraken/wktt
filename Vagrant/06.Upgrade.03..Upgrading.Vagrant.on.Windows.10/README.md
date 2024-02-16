# Upgrading Vagrant on Windows 10 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=_8B-tTDwHQA

## Resources

* 🗨 [Subtitles](subtitles.srt)

## Transcript

We're back on our Windows 10 baremetal environment.
```
PS C:\Users\werekraken> cmd /c ver
...
```

Let's make sure the basic system is up-to-date.
```
PS C:\Users\werekraken> Import-Module PSWindowsUpdate
PS C:\Users\werekraken> Get-WindowsUpdate
```
It is.

If updates are needed, they can be installed with a few extra flags. Be sure to only use the `-AutoReboot` flag if now is a suitable time for a reboot.
```
PS C:\Users\werekraken> Get-WindowsUpdate -AcceptAll -Install -AutoReboot
```

Let's check winget.
```
PS C:\Users\werekraken> winget upgrade
...
```
We can see there are a few upgrades available, including vagrant and VirtualBox.

Let's install these.
```
PS C:\Users\werekraken> winget upgrade --all
...
```

Time for some validation. The upgrades look good.
```
PS C:\Users\werekraken> $env:PATH = $env:PATH + ';C:\Program Files\Oracle\VirtualBox'
PS C:\Users\werekraken> VboxManage --version
...
PS C:\Users\werekraken> vagrant --version
...
```
