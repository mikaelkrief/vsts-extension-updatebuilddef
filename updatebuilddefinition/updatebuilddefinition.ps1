

Write-Host "Starting updatebuilddefinition"

#Run Save-Module -Name VstsTaskSdk -Path .\ for get the Powershell VSTS SDK
# see https://github.com/Microsoft/vsts-task-lib/tree/master/powershell/Docs
Trace-VstsEnteringInvocation $MyInvocation

try {

    $jsonfile = Get-VstsInput -Name jsonfile -Require
    $definitionid = Get-VstsInput -Name definitionid -Require
    $tfsurl = Get-VstsInput -Name tfsurl -Require

    if (Test-Path $jsonfile) {
        $bodyTmp = Get-Content $jsonfile -Raw | ConvertFrom-Json
        $uriDef = "$tfsurl/_apis/build/definitions/$($definitionid)?api-version=4.1-preview.6"
        $resDef = Invoke-RestMethod -Uri $uriDef -Method "GET" -ContentType "application/json" -Headers @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"}
        Write-Host $resDef

        $resDef.variables = $bodyTmp.variables
        $resDef.process = $bodyTmp.process

        $uriRev = "$tfsurl/_apis/build/definitions/$($definitionid)/revisions?api-version=4.1-preview.2"
        $resRev = Invoke-RestMethod -Uri $uriRev -Method "GET" -ContentType "application/json" -Headers @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"}

        $lastRev = $resRev.count
        $resDef.revision = $lastRev
        
        if (!(Test-Path "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\tmp")) {
            New-Item "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\tmp" -ItemType Directory
        }
        if (!(Test-Path "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\$definitionid.json")) {
            New-Item "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\tmp\$definitionid.json" -ItemType File
        }else{

        }

        $resDef | ConvertTo-Json -Depth 20 | Set-Content  "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\tmp\$definitionid.json" 
        $body = Get-Content -Path "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\tmp\$definitionid.json"




        [Microsoft.PowerShell.Commands.WebRequestMethod] $method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Put
        $uri = "$tfsurl/_apis/build/definitions/$($definitionid)?api-version=4.1-preview.6"
        $res = Invoke-RestMethod -Uri $uri -Method $method -Body $body -ContentType "application/json" -Headers @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"}
        Write-Host $res
    }
    else {
        Write-Error "Le fichier $jsonfile n'existe pas"
    }

}
catch [Exception] {    
    Write-Error ($_.Exception.Message)
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

Write-Host "Ending updatebuilddefinition"