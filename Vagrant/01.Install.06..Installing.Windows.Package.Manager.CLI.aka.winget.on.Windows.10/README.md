# Installing Windows Package Manager CLI (aka winget) on Windows 10 [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=NonlGxFD00o

## Resources

🗨 [Subtitles](subtitles.srt)

## Transcript

Here we have Windows 10 with the PSWindowsUpdate PowerShell module installed.
```
PS C:\Users\werekraken> cmd /c ver
...
PS C:\Users\werekraken> Import-Module PSWindowsUpdate
```

Our first step is to ensure that the environment is up-to-date.
```
PS C:\Users\werekraken> Get-WindowsUpdate
```
The basic environment is.

If updates are needed, they can be installed with a few extra flags. Be sure to only use the `-AutoReboot` flag if now is a suitable time for a reboot.
```
PS C:\Users\werekraken> Get-WindowsUpdate -AcceptAll -Install -AutoReboot
```

Now, let's install winget and a few dependencies. Without a package manager, we'll have to install them manually.

The process for each package will look quite similar--we'll download one or more assets, extract as needed, validate what we're about to install, and then install it.

First up is the Windows UI Library, UI Xaml. Let's download the nuget linked in the project's README.

> <br>
> https://github.com/microsoft/microsoft-ui-xaml
> <br><br>

We don't have .NET installed, but--like many package formats--a .nupkg is really just an archive. We'll name our download with the .zip extension since some Windows tools are picky about those.
```
PS C:\Users\werekraken> Invoke-WebRequest -UseBasicParsing -Uri https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3 -OutFile Microsoft.UI.Xaml-2.7.3.zip
...
```

Extract the .zip to get at the .appx file.
```
PS C:\Users\werekraken> Expand-Archive -Path Microsoft.UI.Xaml-2.7.3.zip
...
```

Let's validate the embedded digital signature in the .appx.
```
PS C:\Users\werekraken> Get-AuthenticodeSignature .\Microsoft.UI.Xaml-2.7.3\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx
...
```
Looks good.

Let's install that.
```
PS C:\Users\werekraken> Add-AppxPackage -Path .\Microsoft.UI.Xaml-2.7.3\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx
...
```

Next, we need the Visual C++ Runtime libraries. Let's download the .appx linked in the Visual Studio troubleshooting documentation.
> <br>
> https://learn.microsoft.com/en-us/troubleshoot/developer/visualstudio/cpp/libraries/c-runtime-packages-desktop-bridge
> <br><br>

```
PS C:\Users\werekraken> Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
...
```

Validate the digital signature.
```
PS C:\Users\werekraken> Get-AuthenticodeSignature .\Microsoft.VCLibs.x64.14.00.Desktop.appx
...
```
Good to go.

And install.
```
PS C:\Users\werekraken> Add-AppxPackage -Path .\Microsoft.VCLibs.x64.14.00.Desktop.appx
...
```

With the dependencies installed, we can now install the Windows Package Manager CLI, also known as winget. Let's download the .msixbundle from the project's github releases.
> <br>
> https://github.com/microsoft/winget-cli/releases/tag/v1.4.10173
> <br><br>

```
PS C:\Users\werekraken> Invoke-WebRequest -UseBasicParsing -Uri https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
...
```

This project also provides a SHA-256 of the .msixbundle in the correspondingly named .txt file.
```
PS C:\Users\werekraken> Invoke-WebRequest -UseBasicParsing -Uri https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt
...
```

Let's compare the SHA contained in the .txt file to our downloaded .msixbundle.
```
PS C:\Users\werekraken> cat Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt
...
PS C:\Users\werekraken> Get-FileHash .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
...
```
For basic validation of an asset securely downloaded from a trusted domain--such as this--I'm comfortable with a simple visual comparison. I generally compare the first and last 4-6 characters, then check one or two random spots in the middle. Compare the hashes programmatically as you see fit.

This download looks good to me.

Time to install.
```
PS C:\Users\werekraken> Add-AppxPackage -Path .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
...
```

Let's check our installation. Looks good.
```
PS C:\Users\werekraken> winget --version
...
```
