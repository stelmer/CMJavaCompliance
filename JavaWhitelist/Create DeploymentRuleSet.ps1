$ScriptName = $MyInvocation.MyCommand.path
$Directory = Split-Path $ScriptName
cd $Directory

$Keytool = $null
$jarsigner = $null
$jar = $null
$CacertsArray = @()
# searches through Java install folders for cert importing tools
If(Test-Path "C:\Program Files (x86)\Java") {
    Get-ChildItem "C:\Program Files (x86)\Java" -Include @("jarsigner.exe","keytool.exe","jar.exe") -Recurse | ForEach-Object {
        If($_.Name -eq "jar.exe") {$jar = $_.FullName}
        elseif ($_.Name -eq "keytool.exe") {$Keytool = $_.FullName}
        elseif ($_.Name -eq "jarsigner.exe") {$jarsigner = $_.FullName}
    }
}
If(Test-Path "C:\Program Files\Java") {
    Get-ChildItem "C:\Program Files\Java" -Include @("jarsigner.exe","keytool.exe","jar.exe") -Recurse | ForEach-Object {
        If($_.Name -eq "jar.exe") {$jar = $_.FullName}
        elseif ($_.Name -eq "keytool.exe") {$Keytool = $_.FullName}
        elseif ($_.Name -eq "jarsigner.exe") {$jarsigner = $_.FullName}
    }
}

$keystore = "$Directory\keystore.jks"

Remove-Item "DeploymentRuleSet.jar" -Force -ErrorAction SilentlyContinue

& $Jar -cvf DeploymentRuleSet.jar ruleset.xml
$strOutput = & $keytool -list -keystore $keystore -storepass "changeit" | Out-String
$Alias = $strOutput.Split("`n")
$Alias = $Alias[6]
$Alias = $Alias.Split(",")
$Alias = $Alias[0]
& $jarsigner -verbose -keystore $keystore -signedjar DeploymentRuleSet.jar DeploymentRuleSet.jar -storepass "changeit" $Alias
