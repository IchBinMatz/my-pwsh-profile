
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

$repos = "$env:HOMEPATH\Documents\repos"
oh-my-posh init pwsh | Invoke-Expression
