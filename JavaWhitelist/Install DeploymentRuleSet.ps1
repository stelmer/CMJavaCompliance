<#
    Java DeploymentRuleSet/Certificate Install Script
#>

$ErrorActionPreference = "SilentlyContinue"
$AppID = "38feda06-9583-4595-ad1b-2f83f82fe767"

$ScriptName = $MyInvocation.MyCommand.path
$Directory = Split-Path $ScriptName

Function CopyFiles {
    Param (
        $FileName, $CopyToLocation
    )
    $NewFilePath = "$Directory\$FileName"
    $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $NewFileHash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes($NewFilePath)))
    
    $OldFilePath = "$CopyToLocation\$FileName"
    If (Test-Path $OldFilePath) {
        $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $OldFileHash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes($OldFilePath)))
        If ($OldFileHash -ne $NewFileHash) {
            Try {
                Copy-Item $NewFilePath $CopyToLocation -Force
            }
            catch {
                return $false
            }
        }
    }
    else {
        Try {
            Copy-Item $NewFilePath $CopyToLocation -Force
        }
        catch {
            return $false
        }
    }
    return $true
}

$KeepCopying = $true

If ($KeepCopying) {$KeepCopying = CopyFiles -FileName "DeploymentRuleSet.jar" -CopyToLocation "C:\Windows\Sun\Java\Deployment"}

If ($KeepCopying) {
    $Revisions = (Get-wmiobject -Namespace "root\ccm\clientsdk" -Query "Select Revision from CCM_Application where ID like '%$AppID'").Revision
    $LargeRevision = 0
    Foreach ($Revision in $Revisions) {
        if ($LargeRevision -lt $Revision) { $LargeRevision = $Revision }
    }
    & cmd /c reg add "hklm\Software\CMAppInstalls\$AppID" /v Revision /t REG_SZ /d $LargeRevision /f
}

# Set certificate File name
$CertName = "KeystoreCert.pem"
New-Item -ItemType Directory -Path C:\Windows\Sun\Java\Deployment -ErrorAction SilentlyContinue
Copy-Item "$Directory\DeploymentRuleSet.jar" "C:\Windows\Sun\Java\Deployment\" -Force

#region Install cert
$Keytool = $null
$CacertsArray = @()
# searches through Java install folders for cert importing tools
If(Test-Path "C:\Program Files (x86)\Java") {
    Get-ChildItem "C:\Program Files (x86)\Java" -Include @("cacerts","keytool.exe") -Recurse | ForEach-Object {
        If($_.Name -eq "cacerts") {$CacertsArray += @($_.FullName)}
        elseif ($_.Name -eq "keytool.exe") {cd $_.DirectoryName}
    }
}
If(Test-Path "C:\Program Files\Java") {
    Get-ChildItem "C:\Program Files\Java" -Include @("cacerts","keytool.exe") -Recurse | ForEach-Object {
        If($_.Name -eq "cacerts") {$CacertsArray += @($_.FullName)}
        elseif ($_.Name -eq "keytool.exe") {$Keytool = $_.FullName}
    }
}
$KeytoolPath = "`"$Keytool`""
$CertPath = "`"$Directory\$CertName`""
Foreach ($cacert in $CacertsArray) {
    $CacertPath = "`"$cacert`""
    & cmd /c keytool.exe -importcert -keystore $CacertPath -storepass changeit -file $CertPath -alias JavaCert -noprompt
}
#endregion
