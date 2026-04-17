## ARM64 Printer Driver Notes

Some print drivers are not compatible with ARM64 architecture, and some printers do not have ARM64 drivers available.

These printers are often compatible with standard drivers like:
- Microsoft PS Class
- Microsoft PCL6
- Microsoft IPP

IPP (Internet Printing Protocol) is the same protocol used within Apple AirPrint and is essentially "driverless". Most modern printers support IPP.

The script used here attempts:
1. Microsoft PS Class
2. Microsoft PCL6
3. Defaults to Microsoft IPP

---

## Source Files

Source:
  install.ps1
  uninstall.ps1

- install.ps1 & uninstall.ps1: Standard scripts, no changes required
- Install & Uninstall Commands: Update variables per deployment
- Detection Script: Update variables per deployment

---

## Example Request

- Printer Model: Konica Minolta Bizhub C301i
- IP Address: 192.168.1.30
- Printer Name: Mpls Printer

### Install Command
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1 -PortName "IP_192.168.1.30" -PrinterIP "192.168.1.30" -PrinterName "Mpls Printer"
```

### Uninstall Command
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Uninstall.ps1 -PrinterName "Mpls Printer"
```

---

## Intune Requirements

### Scope to ARM64
Restrict the new installer to only run on ARM64:

Intune > App > Properties > Edit Requirements  
→ Specify systems = Yes  
→ Install on ARM64 System  

<img src="https://github.com/user-attachments/assets/c5a5d9dc-ce93-4799-8e80-3b2c5c768e70" width="585"/>

---

### Restrict failing installer to x64

Intune > App > Properties > Edit Requirements  
→ Specify systems = Yes  
→ Install on x64 System  

<img src="https://github.com/user-attachments/assets/a276ad51-990b-47f8-a1b1-a023fe1e48b2" width="539"/>

---

## Logging

Log file:
C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntunePrinterInstall.log

### Review failed installations

Intune → Device → Collect Diagnostics  
→ Download & Open Folder  
→ ProgramData_Microsoft_IntuneManagementExtension_Logs\IntunePrinterInstall.log  

---

## Source Folder Example

Konica Bizhub C301i ARM64\
└── Source\
    ├── install.ps1
    └── uninstall.ps1

---

## Intune App Packaging Reference

https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare

"When you're generating an .intunewin file, put any files you need to reference into a subfolder of the setup folder. Then, use a relative path to reference the specific file you need."
