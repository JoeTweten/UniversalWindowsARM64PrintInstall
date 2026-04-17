[CmdletBinding()]

Param (
    [Parameter(Mandatory = $True)]
    [String]$PrinterName
)

Try {
    #Remove Printer
    $PrinterExist = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
    if ($PrinterExist) {
        Remove-Printer -Name $PrinterName -Confirm:$false
    }

    #Remove Intune printer install log if it exists
    $intunePrinterLogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntunePrinterInstall.log"
    if (Test-Path -Path $intunePrinterLogPath) {
        Remove-Item -Path $intunePrinterLogPath -Force -ErrorAction SilentlyContinue
    }
}
Catch {
    Write-Warning "Error removing Printer"
    Write-Warning "$($_.Exception.Message)"
}
