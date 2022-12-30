
Install-Module powershell-yaml
Import-Module powershell-yaml

$ProfilePath = (Get-Item $PROFILE).DirectoryName
New-Item -type Directory "$ProfilePath\completions" -Force
$CompletionsPath = "$ProfilePath\completions\"

Write-Output "generate Profile"
Write-Output "# generated Profile" > $PROFILE

Write-Output "installing completions:"
$softwares = Get-Content software.yaml | ConvertFrom-Yaml 
$softwares | Foreach-Object -ThrottleLimit 5 -Parallel {
  #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname

  if ($PSItem.ContainsKey("module")){
    $module = $PSItem.module
    Write-Output $module
    Install-Module $module -Scope CurrentUser -AllowClobber
    Write-Output "Import-Module $module" >> $USING:PROFILE
  }
  if ($PSItem.ContainsKey("command")){
    $folder = $USING:CompletionsPath
    $filePath = $PSItem.exe | % {$folder + $_ + ".ps1"}
    Write-Output $filePath
    $cmdargs = $PSItem["command"].Split(" ")
    & $PSItem["exe"] @cmdargs > $filePath
  }
}
Get-ChildItem .\completions\ *.ps1 | Copy-Item -Destination $CompletionsPath
Get-ChildItem $CompletionsPath *.ps1 | Foreach-Object  {
  $fileName = $_.Name
  ". $CompletionsPath$fileName" >> $PROFILE
}
Get-Content profile.ps1 >> $PROFILE
Write-Output "Finished Writing to Profile:"
Write-Output $PROFILE