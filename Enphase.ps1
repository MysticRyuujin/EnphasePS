<#
.Synopsis
   Get Enphase Solar Production, Consumption, and Net Use
.DESCRIPTION
   If you have not changed the password to your controller use the -SerialNumber, otherwise use -Credentials or -CustomPassword
.EXAMPLE
   Get-SolarStatus -Controller "http://192.168.1.207" -SerialNumber 1234567890
.EXAMPLE
   Get-SolarStatus -Controller "http://enphase.local" -Credentials (Get-Credential "envoy")
.EXAMPLE
   Get-SolarStatus -Controller "http://enphase.local" -CustomPassword 'MyCustomPassword'
#>
function Get-SolarStatus {
    [CmdletBinding(DefaultParameterSetName="DefaultPassword")]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Controller,

        [Parameter(Mandatory=$true, ParameterSetName = "DefaultPassword")]
        [string]$SerialNumber,

        [Parameter(Mandatory=$true, ParameterSetName = "CustomPassword")]
        [string]$CustomPassword,

        [Parameter(Mandatory=$true, ParameterSetName = "Credentials")]
        [pscredential]$Credentials
    )

    if ($PSCmdlet.ParameterSetName -eq "DefaultPassword") {
        $SecPassword = ConvertTo-SecureString ($SerialNumber.Remove(0,($SerialNumber.Length - 6))) -AsPlainText -Force
        $Credentials = New-Object System.Management.Automation.PSCredential ("envoy", $SecPassword)
    } elseif ($PSCmdlet.ParameterSetName -eq "CustomPassword") {
        $SecPassword = ConvertTo-SecureString $CustomPassword -AsPlainText -Force
        $Credentials = New-Object System.Management.Automation.PSCredential ("envoy", $SecPassword)
    }
    
    if ($PSVersionTable.PSVersion.Major -gt 5) {
        $Results = Invoke-RestMethod -Uri ($Controller + "/production.json") -Credential $Credentials -AllowUnencryptedAuthentication
    } else {
        $Results = Invoke-RestMethod -Uri ($Controller + "/production.json") -Credential $Credentials
    }
    
    $TotalConsumption = ($Results.consumption | Where-Object { $_.measurementType -eq "total-consumption" }).wNow
    $TotalProduction = ($Results.production[1]).wNow
    $NetPowerStatus = ($Results.consumption | Where-Object { $_.measurementType -eq "net-consumption" }).wNow
    
    @{
        "Production" = [string]::Format('{0:N0}',$TotalProduction)
        "Consumption" = [string]::Format('{0:N0}',$TotalConsumption)
        "Net Usage" = [string]::Format('{0:N0}',$NetPowerStatus)
    }
}
