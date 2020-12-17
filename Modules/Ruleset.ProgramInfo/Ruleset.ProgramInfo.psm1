
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019, 2020 metablaster zebal@protonmail.ch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# Initialization
Set-Variable -Name ThisModule -Scope Script -Option ReadOnly -Force -Value ((Get-Item $PSCommandPath).Basename)

# Imports
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 -InModule
. $PSScriptRoot\..\ModulePreferences.ps1

#
# Script imports
# TODO: Executables involved in rules which are installed into ProgramFiles\Common Files require
# separate search algorithm (function) instead of using Update-Table, these are present only
# if program in question is installed, likely into ProgramFiles
# Example programs: Adobe and Java
#

$ScriptsToProcess = @(
	"TargetProgram"
)

foreach ($Script in $ScriptsToProcess)
{
	Write-Debug -Message "[$ThisModule] Importing script: Scripts\$Script.ps1"
	. "$PSScriptRoot\Scripts\$Script.ps1"
}

$PrivateScripts = @(
	"Edit-Table"
	"Initialize-Table"
	"Show-Table"
	"Update-Table"
)

foreach ($Script in $PrivateScripts)
{
	Write-Debug -Message "[$ThisModule] Importing script: Private\$Script.ps1"
	. "$PSScriptRoot\Private\$Script.ps1"
}

$PublicScripts = @(
	"External\Get-SqlServerInstance"
	"Find-Installation"
	"Format-Path"
	"Get-AllUserSoftware"
	"Get-AppCapability"
	"Get-AppSID"
	"Get-ExecutablePath"
	"Get-NetFramework"
	"Get-OneDrive"
	"Get-SqlManagementStudio"
	"Get-SystemApps"
	"Get-SystemSoftware"
	"Get-UserApps"
	"Get-UserSoftware"
	"Get-WindowsDefender"
	"Get-WindowsKit"
	"Get-WindowsSDK"
	"Test-Environment"
	"Test-File"
	"Test-Installation"
	"Test-Service"
)

foreach ($Script in $PublicScripts)
{
	Write-Debug -Message "[$ThisModule] Importing script: Public\$Script.ps1"
	. "$PSScriptRoot\Public\$Script.ps1"
}

#
# Module variables
#

# Installation table holds user and program directory pair
if ($Develop)
{
	# TODO: script scope variable should be exportable?
	Write-Debug -Message "[$ThisModule] Initialize Global variable: InstallTable"
	Remove-Variable -Name InstallTable -Scope Script -ErrorAction Ignore
	Set-Variable -Name InstallTable -Scope Global -Value $null
}
else
{
	Write-Debug -Message "[$ThisModule] Initialize module variable: InstallTable"
	Remove-Variable -Name InstallTable -Scope Global -ErrorAction Ignore
	Set-Variable -Name InstallTable -Scope Script -Value $null
}

Write-Debug -Message "[$ThisModule] Initialize module readonly variable: SystemPrograms"
# Programs installed for all users
New-Variable -Name SystemPrograms -Scope Script -Option ReadOnly -Value (Get-SystemSoftware -Computer $PolicyStore)

Write-Debug -Message "[$ThisModule] Initialize module readonly variable: ExecutablePaths"
# Programs installed for all users
New-Variable -Name ExecutablePaths -Scope Script -Option ReadOnly -Value (Get-ExecutablePath -Computer $PolicyStore)

Write-Debug -Message "[$ThisModule] Initialize module readonly variable: AllUserPrograms"
# Programs installed for all users
New-Variable -Name AllUserPrograms -Scope Script -Option ReadOnly -Value (Get-AllUserSoftware -Computer $PolicyStore)

<# Opening keys, naming convention as you drill down the keys

Object (key)/	Key Path(s) name/	Sub key names (multiple)
RemoteKey	/	RegistryHive
Array of keys/	HKLM
RootKey		/	HKLMRootKey		/	HKLMNames
SubKey		/	HKLMSubKey		/	HKLMSubKeyNames
Key			/	HKLMKey			/	HKLMKeyNames
SpecificNames...
*KeyName*Entry
#>

<# In order listed
FUNCTIONS
	1 RegistryKey.OpenSubKey
	2 RegistryKey.GetValue
	3 RegistryKey.OpenRemoteBaseKey
	4 RegistryKey.GetSubKeyNames
	5 RegistryKey.GetValueNames

RETURNS
	1 The subkey requested, or null if the operation failed.
	2 The value associated with name, or null if name is not found.
	3 The requested registry key.
	4 An array of strings that contains the names of the subkeys for the current key.
	5 An array of strings that contains the value names for the current key.

EXCEPTION
	ArgumentNullException
	1 name is null.
	3 machineName is null.

	ArgumentException
	3 hKey is invalid.

	ObjectDisposedException
	1, 2, 4, 5 The RegistryKey is closed (closed keys cannot be accessed).

	SecurityException
	1 The user does not have the permissions required to access the registry key in the specified mode.

	SecurityException
	2, 5 The user does not have the permissions required to read from the registry key.
	3 The user does not have the proper permissions to perform this operation.
	4 The user does not have the permissions required to read from the key.

	IOException
	2 The RegistryKey that contains the specified value has been marked for deletion.
	3 machineName is not found.
	4, 5 A system error occurred, for example the current key has been deleted.

	UnauthorizedAccessException
	2, 3, 4, 5 The user does not have the necessary registry rights.
#>
