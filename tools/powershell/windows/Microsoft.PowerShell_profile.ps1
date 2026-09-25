Set-Alias -Name docker -Value podman
Remove-Item Alias:\ls -ErrorAction SilentlyContinue
Set-Alias -Name ls -Value eza

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# mise (env vars + tool paths per directory)
mise activate powershell | Out-String | Invoke-Expression
