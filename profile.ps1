
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

$repos = "$env:HOMEPATH\Documents\repos"
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/paradox.omp.json" | Invoke-Expression
# disable VenvPrompt because the oh-my-posh-theme will show it anyway
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1