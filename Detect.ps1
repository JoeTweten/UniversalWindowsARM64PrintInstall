$PrinterName = "Mpls Printer"
$PortName    = "IP_192.168.1.30"
$PrinterIP   = "192.168.1.30"

$LogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntunePrinterDetect.log"

if (Test-Path $LogPath) {
    if ((Get-Item $LogPath).Length -gt 1MB) {
        Clear-Content $LogPath
    }
}

function Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$ts] $Message"
}

$validDrivers = @(
    "Microsoft PS Class Driver",
    "Microsoft PCL6 Class Driver",
    "Microsoft IPP Class Driver"
)

Log "Starting detection for '$PrinterName'"

$printer = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
if (-not $printer) {
    Log "NOT DETECTED: Printer missing"
    Write-Output "Printer missing"
    exit 1
}

if ($printer.PortName -ne $PortName) {
    Log "NOT DETECTED: Wrong port ($($printer.PortName))"
    Write-Output "Wrong port"
    exit 1
}

if ($validDrivers -notcontains $printer.DriverName) {
    Log "NOT DETECTED: Invalid driver ($($printer.DriverName))"
    Write-Output "Invalid driver"
    exit 1
}

$port = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue
if (-not $port) {
    Log "NOT DETECTED: Port missing"
    Write-Output "Port missing"
    exit 1
}

if ($port.PrinterHostAddress -ne $PrinterIP) {
    Log "NOT DETECTED: Port IP mismatch ($($port.PrinterHostAddress))"
    Write-Output "Port IP mismatch"
    exit 1
}

Log "DETECTED: Printer correctly configured"
Write-Output "Installed"
exit 0
