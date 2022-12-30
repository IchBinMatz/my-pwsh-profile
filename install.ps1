
Install-Module powershell-yaml
Import-Module powershell-yaml

$ProfilePath = (Get-Item $PROFILE).DirectoryName
New-Item -type Directory "$ProfilePath\completions" -Force
$CompletionsPath = "$ProfilePath\completions\"

echo "generate Profile"
echo "# generated Profile" > $PROFILE

echo "installing completions:"
$softwares = Get-Content software.yaml | ConvertFrom-Yaml 
$softwares | Foreach-Object -ThrottleLimit 5 -Parallel {
  #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname

  if ($PSItem.ContainsKey("module")){
    $module = $PSItem.module
    echo $module
    Install-Module $module -Scope CurrentUser -AllowClobber
    echo "Import-Module $module" >> $USING:PROFILE
  }
  if ($PSItem.ContainsKey("command")){
    $folder = $USING:CompletionsPath
    $filePath = $PSItem.exe | % {$folder + $_ + ".ps1"}
    echo $filePath
    $args = $PSItem["command"].Split(" ")
    & $PSItem["exe"] @args > $filePath
  }
}
Get-ChildItem .\completions\ *.ps1 | Copy-Item -Destination $CompletionsPath
Get-ChildItem $CompletionsPath *.ps1 | Foreach-Object  {
  $fileName = $_.Name
  ". $CompletionsPath$fileName" >> $PROFILE
}
Get-Content profile.ps1 >> $PROFILE
echo "Finished Writing to Profile:"
echo $PROFILE