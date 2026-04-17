Intune App Packaging Guide
MS Learn - Intune App Packing: https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare
"When you're generating an .intunewin file, put any files you need to reference into a subfolder of the setup folder. 
Then, use a relative path to reference the specific file you need. For example:

Setup source folder: c:\testapp\v1.0
License file: c:\testapp\v1.0\licenses\license.txt

Refer to the license.txt file by using the relative path licenses\license.txt."

~\Source: include install.ps1, uninstall.ps1
install.ps1 & uninstall.ps1: Variables are declared through install/uninstall command, do not update per installation.
Install & uninstall command: Update variables per installation
Detection Script: Update variables per installation


Example Request throughout documents:
Printer Model: Konica Minolta Bizhub c301i
IP Address: 192.168.1.30
Printer Name: Mpls Printer

Scope to ARM64
Restrict the new installer to only run on ARM64.
Select your app within Intune, Navigate to Properties -> Edit Requirements -> Select "Yes. Specify the systems the app can be installed on." -> Set to "Install on ARM64 System"

Restrict the failing installer to only run on x64:
Find the failing app within Intune -> Navigate to Properties -> Edit Requirements -> Select "Yes. Specify the systems the app can be installed on." -> Set to "Install on x64 System"
<img width="539" height="174" alt="image" src="https://github.com/user-attachments/assets/ad864887-3dd0-4ece-b644-0253837d866f" />


Set Supercedence

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
