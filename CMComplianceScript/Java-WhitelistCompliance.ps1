#Current version, run this to pull the current stamp
#Update '\\server\share' to your common share location 
(ls "\\server\share\JWL\DeploymentRuleset.jar").LastWriteTimeUtc.ToFileTime()
#My current version = 130913107357363236

########################  JAVA Whitelist Compliance script Start  #############################

$localWL = "C:\windows\Sun\java\deployment\DeploymentRuleset.jar"
$sourceWL = "\\server\share\JWL\DeploymentRuleset.jar"

if (Test-Path $localWL) {
    #lets update if if we are not compliant.
    if ((ls $localWL).LastWriteTimeUtc.ToFileTime() -ne 130913107357363236) {
        Write-Host "Non-Compliant, copying file...."
        cp -Path $sourceWL -Destination $localWL -Force
    } else {
        Write-Host "Compliant"
    } 
} Else {
Write-Host "Non-compliant"
}

#########################  JAVA Whitelist Compliance script End  ##############################

#View our class
Get-WmiObject -class CM_JavaUsageTracking

#Delete our class
Remove-WmiObject -class CM_JavaUsageTracking