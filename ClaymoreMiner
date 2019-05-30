# Start or Stop the miner
function Set-MinerStatus {
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Start","Stop")]
        [string]$Status
    )
    switch ($Status) {
        "Start" {
            $JSON = '{"id":0,"jsonrpc":"2.0","method":"control_gpu", "psw": "<redacted>", "params":["-1", "1"]}'
            break
        }
        "Stop" {
            $JSON = '{"id":0,"jsonrpc":"2.0","method":"control_gpu", "psw": "<redacted>", "params":["-1", "0"]}'
        }
    }
    $TCPConnection = New-Object System.Net.Sockets.TcpClient("127.0.0.1", 3333)
    $TCPStream = $tcpConnection.GetStream()
    $Writer = New-Object System.IO.StreamWriter($tcpStream)
    $Writer.AutoFlush = $true
    if ($TCPConnection.Connected) {
        [void]$writer.WriteLine($JSON)
        $writer.Close()
        $tcpConnection.Close()
    } else {
        Write-Warning "TCP Connection Failed"
    }
}

function Get-NetPowerText {
    if ($Global:NetPowerAverage -gt 0) {
        Write-Host "Importing $($Global:NetPowerAverage) watts" -ForegroundColor Red
    } else {
        Write-Host "Exporting $($Global:NetPowerAverage) watts" -ForegroundColor Green
    }
}

# Create, Register, and Start a timer that updates the Net Power Average every 10 seconds
$Timer = New-Object Timers.Timer
$Timer.Interval = 10000 # 10 seconds
$Timer.Enabled = $true
$null = Register-ObjectEvent -InputObject $Timer -EventName elapsed –SourceIdentifier ([guid]::NewGuid().guid) -Action {
    function Get-NetPower {
        $SecPassword = ConvertTo-SecureString ('<redacted>') -AsPlainText -Force
        $SolarCreds = New-Object System.Management.Automation.PSCredential ("envoy", $SecPassword)
        try {
            return ((Invoke-RestMethod -Uri ("http://enphase.local/production.json") -Credential $SolarCreds -ErrorAction Stop).consumption | Where-Object { $_.measurementType -eq "net-consumption" }).wNow -as [int]
        } catch {
            return 0
        }
    }
    $Global:NetPowerAverage = $Global:NetPowerAverage - ($Global:NetPowerAverage / 6) -as [int]
    $Global:NetPowerAverage = $Global:NetPowerAverage + ((Get-NetPower) / 6) -as [int]
}
$Timer.Start()

# Start the miner
$Miner = Start-Process -NoNewWindow C:\Ethereum\Mining\Claymore\EthDcrMiner64.exe -PassThru
Start-Sleep -Seconds 30

# Update the status of the miner every minute
$Running = $true
while ($true) {
    Get-NetPowerText
    if (($Global:NetPowerAverage -lt -250) -and !$Running) {
        try {
            Write-Host "Starting Miner" -ForegroundColor Green
            Set-MinerStatus -Status Start
            $Running = $true
        } catch {
            Write-Warning "Failed to start"
            Write-Error $_
        }
    } elseif (($Global:NetPowerAverage -ge 0) -and $Running) {
        try {
            Write-Host "Stopping Miner" -ForegroundColor Red
            Set-MinerStatus -Status Stop
            $Running = $false
        } catch {
            Write-Warning "Failed to stop"
            Write-Error $_
        }
    }
    Start-Sleep -Seconds 60
}

$Miner.Kill()
