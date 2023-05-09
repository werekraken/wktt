# Installing Vagrant on Windows 10 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=WeROCNVegd4

## Transcript

Here we have Windows 10 with the PSWindowsUpdate PowerShell module and winget installed.
```
PS C:\Users\werekraken> cmd /c ver
...
PS C:\Users\werekraken> Import-Module PSWindowsUpdate
PS C:\Users\werekraken> winget --version
...
```

First, we want to ensure that our environment is up-to-date.
```
PS C:\Users\werekraken> Get-WindowsUpdate
```
The basic environment is.

If updates are needed, they can be installed with a few extra flags. Be sure to only use the `-AutoReboot` flag if now is a suitable time for a reboot.
```
PS C:\Users\werekraken> Get-WindowsUpdate -AcceptAll -Install -AutoReboot
```

Let's check winget.
```
PS C:\Users\werekraken> winget source update
...
```
If you have a fresh install of winget, as I do, you should see an agreement prompt for the msstore source. Follow the link to read the terms and agree if you so choose.
```
PS C:\Users\werekraken> winget upgrade
...
```
winget managed installs are up-to-date too.

If winget upgrades are needed, they can be install with the `--all` flag.
```
PS C:\Users\werekraken> winget upgrade --all
...
```

Our goal here is to install vagrant and VirtualBox. To do so, we first need to install Microsoft Visual C++ Redistributable--a dependency of VirtualBox.
```
PS C:\Users\werekraken> winget install Microsoft.VCRedist.2015+.x64
...
```

Now, we can install VirtualBox.
```
PS C:\Users\werekraken> winget install Oracle.VirtualBox
...
```

Let's do some basic validation. VirtualBox looks good.
```
PS C:\Users\werekraken> $env:PATH = $env:PATH + ';C:\Program Files\Oracle\VirtualBox'
PS C:\Users\werekraken> VboxManage --version
...
```

Next, let's install vagrant.
```
PS C:\Users\werekraken> winget install Hashicorp.Vagrant
...
```

VirtualBox is a well-known, cross-platform hypervisor and provides a virtualization platform upon which vagrant can run machines.

vagrant calls the virtualization platforms it can use providers.

VirtualBox happens to be vagrant's default provider making it arguably the easiest way to get started.

vagrant supports several other providers, either natively or through installable plugins.

Time for some more basic validation. vagrant looks good too.
```
PS C:\Users\werekraken> $env:PATH = $env:PATH + ';C:\HashiCorp\Vagrant\bin'
PS C:\Users\werekraken> vagrant --version
...
```
