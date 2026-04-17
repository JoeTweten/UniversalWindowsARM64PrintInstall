[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$PortName,
    [Parameter(Mandatory = $true)]
    [string]$PrinterIP,
    [Parameter(Mandatory = $true)]
    [string]$PrinterName
)
# ---- IME Logging ----
$LogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntunePrinterInstall.log"
function Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$ts] $Message"
}
$ThrowBad = $null
# Relaunch in 64-bit PowerShell if needed
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    try {
        $relaunchArgs = @(
            '-ExecutionPolicy', 'Bypass',
            '-File', "`"$PSCommandPath`"",
            '-PortName', "`"$PortName`"",
            '-PrinterIP', "`"$PrinterIP`"",
            '-PrinterName', "`"$PrinterName`""
        )
        $proc = Start-Process `
            -FilePath "$ENV:WINDIR\SysNative\WindowsPowerShell\v1.0\powershell.exe" `
            -ArgumentList $relaunchArgs `
            -Wait `
            -PassThru
        exit $proc.ExitCode
    }
    catch {
        Write-Error "Failed to relaunch in 64-bit PowerShell: $($_.Exception.Message)"
        exit 1
    }
}
Log "##################################"
Log "Installation started"
Log "##################################"
Log "Port Name: $PortName"
Log "Printer IP: $PrinterIP"
Log "Printer Name: $PrinterName"
if (-not $ThrowBad) {
    try {
        $Spooler = Get-Service -Name Spooler -ErrorAction Stop
        if ($Spooler.Status -ne 'Running') {
            Log "Starting Print Spooler service"
            Start-Service -Name Spooler -ErrorAction Stop
        }
        $drivers = Get-PrinterDriver | Select-Object -ExpandProperty Name
        if ($drivers -contains "Microsoft PS Class Driver") {
            $DriverName = "Microsoft PS Class Driver"
        }
        elseif ($drivers -contains "Microsoft PCL6 Class Driver") {
            $DriverName = "Microsoft PCL6 Class Driver"
        }
        elseif ($drivers -contains "Microsoft IPP Class Driver") {
            $DriverName = "Microsoft IPP Class Driver"
        }
        else {
            throw "No compatible class driver found on this device."
        }
        Log "Selected driver: $DriverName"
    }
    catch {
        Write-Warning "Driver validation failed"
        Write-Warning "$($_.Exception.Message)"
        Log "Driver validation failed"
        Log "Exception message: $($_.Exception.Message)"
        Log "Full error: $($_ | Out-String)"
        $ThrowBad = $true
    }
}
if (-not $ThrowBad) {
    try {
        $PortExist = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue
        if (-not $PortExist) {
            Log "Adding printer port '$PortName' for host '$PrinterIP'"
            Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP -ErrorAction Stop
        }
        elseif ($PortExist.PrinterHostAddress -ne $PrinterIP) {
            Log "Printer port '$PortName' exists but points to '$($PortExist.PrinterHostAddress)'; recreating for '$PrinterIP'"
            $queuesUsingPort = Get-Printer | Where-Object { $_.PortName -eq $PortName }
            foreach ($q in $queuesUsingPort) {
                Log "Removing printer queue '$($q.Name)' (uses port '$PortName') so the port can be reconfigured"
                Remove-Printer -Name $q.Name -ErrorAction Stop
            }
            Remove-PrinterPort -Name $PortName -ErrorAction Stop
            Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP -ErrorAction Stop
            Log "Printer port '$PortName' reconfigured successfully"
        }
        else {
            Log "Printer port '$PortName' already exists with correct host address"
        }
    }
    catch {
        Write-Warning "Error creating printer port"
        Write-Warning "$($_.Exception.Message)"
        Log "Error creating printer port"
        Log "Exception message: $($_.Exception.Message)"
        Log "Full error: $($_ | Out-String)"
        $ThrowBad = $true
    }
}
if (-not $ThrowBad) {
    try {
        $PrinterExist = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
        if (-not $PrinterExist) {
            Log "Adding printer '$PrinterName'"
            Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName -ErrorAction Stop
            Log "Printer '$PrinterName' added successfully"
        }
        elseif (($PrinterExist.PortName -eq $PortName) -and ($PrinterExist.DriverName -eq $DriverName)) {
            Log "Printer '$PrinterName' already exists with correct port and driver; no changes needed"
        }
        else {
            Log "Printer '$PrinterName' exists but port or driver differs; recreating"
            Remove-Printer -Name $PrinterName -ErrorAction Stop
            Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName -ErrorAction Stop
            Log "Printer '$PrinterName' reconfigured successfully"
        }
        $PrinterExist2 = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
        if (-not $PrinterExist2) {
            throw "Printer '$PrinterName' was not found after installation."
        }
    }
    catch {
        Write-Warning "Error creating printer"
        Write-Warning "$($_.Exception.Message)"
        Log "Error creating printer"
        Log "Exception message: $($_.Exception.Message)"
        Log "Full error: $($_ | Out-String)"
        $ThrowBad = $true
    }
}
if ($ThrowBad) {
    Write-Error "An error was thrown during installation. Installation failed."
    Log "Installation failed"
    exit 1
}
else {
    Log "Installation completed successfully"
    exit 0
}
