
# Veeam Credential Recovery

This repository contains scripts for recovering passwords from the
Veeam Backup and Replication credential manager.

## Veeam-Get-Creds.ps1
A PowerShell script for getting and decrypting accounts directly from the Veeam's database.

**Usage**
1. Run as administrator (elevated) in PowerShell on a host in a Veeam server.

## VeeamGetCreds.yaml
PowerShell Empire module with adapted Veeam-Get-Creds.ps1 script.

**Usage**
1. copy VeeamGetCreds.yaml to empire/server/modules/powershell/credentials/ folder
2. Run Empire server and client
3. Use as usual Empire module by name /powershell/credentials/VeeamGetCreds


## veampot.py
Python script to emulate vSphere responses to retrieve stored credentials from Veeam.

**Usage**
1. Run the script ./veeampot.py
2. Start the  VMware vSphere Server Add Wizard from the Infrastructure section
3. Enter the address and port (default 8443) of the host on which the script is running
4. Select an account and connect (ignore the message about the invalid certificate)
5. The script will print the credentials sent by Veeam


## Warning
The script is written for educational purposes. Use only if you have permission to disclose credentials.
