# Installing the PSWindowsUpdate PowerShell Module on Windows 10 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=A0Gi5EL7odA

## Resources

🗨 [Subtitles](subtitles.srt)

## Transcript

Here we have a fresh install of Windows 10.
```
PS C:\Users\werekraken> cmd /c ver
...
```

Let's install the PSWindowsUpdate module. With it we can manage updates from within PowerShell.
```
PS C:\Users\werekraken> Install-Module PSWindowsUpdate
...
```
PowerShell Gallery is the central repository for PowerShell code. This includes both code projects from Microsoft and from the greater PowerShell community. Research PSWindowsUpdate and PSGallery as needed and agree to the prompt if you so choose.

My current environment is Windows 10 Home Edition where the default execution policy is `Restricted`.
```
PS C:\Users\werekraken> Get-ExecutionPolicy
...
```
This prevents scripts, which we now need, from running.

I'm going to set my execution policy to `RemoteSigned`, the default for Windows Server.
```
PS C:\Users\werekraken> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
...
```
Check that you also have an execution policy which allows scripts to run--preferably the least permissive policy suitable for your environment. You can follow the link in the prompt for more information on execution policies.

Now, we can import the module.
```
PS C:\Users\werekraken> Import-Module PSWindowsUpdate
```

Let's ensure that our environment is up-to-date.
```
PS C:\Users\werekraken> Get-WindowsUpdate
```
It is.

If updates are needed, they can be installed with a few extra flags. Be sure to only use the `-AutoReboot` flag if now is a suitable time for a reboot.
```
PS C:\Users\werekraken> Get-WindowsUpdate -AcceptAll -Install -AutoReboot
```
And we're done.
