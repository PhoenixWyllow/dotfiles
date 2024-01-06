Make sure git-scm (and optionally github-cli) are installed and configured.

The terminal prompt requires starship and nerdfonts to be installed.

in Linux use:
```shell
curl https://gist.githubusercontent.com/PhoenixWyllow/3ca15ab36343cdb7647633b9538bfdb0/raw/linux-apply-dotfiles.sh | /bin/bash
```

in Windows use:
```powershell
& ([scriptblock]::Create((curl https://gist.githubusercontent.com/PhoenixWyllow/f9f3950ec3bb4ef11e229d6761c77c5e/raw/win-apply-dotfiles.ps1).Content))
```

For Windows: The powershell profile I use is stored in onedrive since my documents are mapped there already.
I use this configuration in my profile to have portability of a `dotfiles` alias and configure neovim to use a conventional xdg path:

```powershell
function Invoke-GitDotFiles {
    git --git-dir=$HOME/.cfg/ --work-tree=$HOME $args
}
Set-Alias -Name dotfiles -Value Invoke-GitDotFiles
#endregion

$env:XDG_CONFIG_HOME = "$HOME/.config"
```
