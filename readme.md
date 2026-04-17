Some print drivers are not compatible with ARM64 architecture, and some Printers do not have ARM64 drivers available.
These printers are often compatible with standard drivers like: Microsoft PS Class, Microsoft PCL6, or Microsoft IPP.
IPP, Internet Printing Protocol, is the same protocol used within Apple AirPrint, and is essentially "Driverless". Most modern printers support IPP. 
The script used here attempts to install Microsoft PS Class, then Microsoft PCL6, and defaults to Microsoft IPP

~\Source: include install.ps1, uninstall.ps1

install.ps1 & uninstall.ps1:  These scripts are standard, no need to update per installation.
Install & uninstall command: Printer variables are declared through the install and uninstall commands, update these per installation
Detection Script: Update Variables per installation

Example Request:
Printer Model: Konica Minolta Bizhub c301i
IP Address: 192.168.1.30
Printer Name: Mpls Printer

Install Command:
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1 -PortName "IP_192.168.1.30" -PrinterIP "192.168.1.30" -PrinterName "Mpls Printer"
Uninstall Command:
powershell.exe -ExecutionPolicy Bypass -File .\Uninstall.ps1 -PrinterName "Mpls Printer"

Scope to ARM64
Restrict the new installer to only run on ARM64.
Select your app within Intune, Navigate to Properties -> Edit Requirements -> Select "Yes. Specify the systems the app can be installed on." -> Set to "Install on ARM64 System"
<img width="585" height="171" alt="image" src="https://github.com/user-attachments/assets/c5a5d9dc-ce93-4799-8e80-3b2c5c768e70" />

Restrict the failing installer to only run on x64:
Find the failing app within Intune -> Navigate to Properties -> Edit Requirements -> Select "Yes. Specify the systems the app can be installed on." -> Set to "Install on x64 System"
<img width="539" height="174" alt="image" src="https://github.com/user-attachments/assets/a276ad51-990b-47f8-a1b1-a023fe1e48b2" />


Logging
Log file: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntunePrinterInstall.log

To review failed installations:
"Collect Diagnostics" from the device via Intune > Download & Open Folder >
~\(67) FoldersFiles ProgramData_Microsoft_IntuneManagementExtension_Logs\IntunePrinterInstall.log
Source Folder
Source Folder needs to include install.ps1 & uninstall.ps1,

~\Konica Bizhub C301i ARM64\Source:
|   install.ps1
|   uninstall.ps1

Intune App Packaging Reference

MS Learn - Intune App Packing: https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare
"When you're generating an .intunewin file, put any files you need to reference into a subfolder of the setup folder. 
Then, use a relative path to reference the specific file you need. For example:
