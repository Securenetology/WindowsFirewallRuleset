
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019-2024 metablaster zebal@protonmail.ch

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

<#
.SYNOPSIS
Inbound firewall rules for wireless networking

.DESCRIPTION
The following predefined groups are included:
1. WI-FI Direct network discovery
2. Wireless display
3. Wireless protable devices
4. WLAN Service WFD*

.PARAMETER Domain
Computer name onto which to deploy rules

.PARAMETER Trusted
If specified, rules will be loaded for executables with missing or invalid digital signature.
By default an error is generated and rule isn't loaded.

.PARAMETER Quiet
If specified, it suppresses warning, error or informationall messages if user specified or default
program path does not exist or if it's of an invalid syntax needed for firewall.

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\WirelessNetworking.ps1

.INPUTS
None. You cannot pipe objects to WirelessNetworking.ps1

.OUTPUTS
None. WirelessNetworking.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
	[Parameter()]
	[Alias("ComputerName", "CN")]
	[string] $Domain = [System.Environment]::MachineName,

	[Parameter()]
	[switch] $Trusted,

	[Parameter()]
	[switch] $Quiet,

	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\..\Config\ProjectSettings.ps1 $PSCmdlet -Domain $Domain
Initialize-Project
. $PSScriptRoot\DirectionSetup.ps1

Import-Module -Name Ruleset.UserInfo

# Setup local variables
$Group = "Wireless Networking"
$LocalInterface = "Wireless"
$Accept = "Inbound rules for wireless networking will be loaded, recommended in specific scenarios for wireless networks"
$Deny = "Skip operation, inbound rules for wireless networking will not be loaded into firewall"
if (!(Approve-Execute -Accept $Accept -Deny $Deny -ContextLeaf $Group -Force:$Force)) { exit }

$PSDefaultParameterValues["Test-ExecutableFile:Quiet"] = $Quiet
$PSDefaultParameterValues["Test-ExecutableFile:Force"] = $Trusted -or $SkipSignatureCheck
#endregion

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore

#
# Predefined rules for Wireless Display
#

$UserModeDrivers = Get-SDDL -Domain "NT AUTHORITY" -User "USER MODE DRIVERS"
$Program = "%SystemRoot%\System32\WUDFHost.exe"
if ((Test-ExecutableFile $Program) -or $ForceLoad)
{
	# TODO: local user may need to be "Any", needs testing.
	New-NetFirewallRule -DisplayName "Wireless Display" `
		-Platform $Platform -PolicyStore $PolicyStore -Profile Private, Domain `
		-Service Any -Program $Program -Group $Group `
		-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
		-LocalAddress Any -RemoteAddress Any `
		-LocalPort 443 -RemotePort Any `
		-LocalUser $UserModeDrivers -EdgeTraversalPolicy Block `
		-InterfaceType $LocalInterface `
		-Description "Driver Foundation - User-mode Driver Framework Host Process.
The driver host process (Wudfhost.exe) is a child process of the driver manager service.
loads one or more UMDF driver DLLs, in addition to the framework DLLs." | Format-RuleOutput
}

$Program = "%SystemRoot%\System32\CastSrv.exe"
if ((Test-ExecutableFile $Program) -or $ForceLoad)
{
	# TODO: remote port unknown, rule added because predefined rule for UDP exists
	New-NetFirewallRule -DisplayName "Wireless Display Infrastructure back channel" `
		-Platform $Platform -PolicyStore $PolicyStore -Profile Private, Domain `
		-Service Any -Program $Program -Group $Group `
		-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
		-LocalAddress Any -RemoteAddress Any `
		-LocalPort 7250 -RemotePort Any `
		-LocalUser Any -EdgeTraversalPolicy Block `
		-InterfaceType $LocalInterface `
		-Description "Miracast is a Wi-Fi display certification program announced by Wi-Fi Alliance for
seamlessly displaying video between devices.
Users attempt to connect to a Miracast receiver as they did previously.
When the list of Miracast receivers is populated, Windows 10 will identify that the receiver is
capable of supporting a connection over the infrastructure.
When the user selects a Miracast receiver, Windows 10 will attempt to resolve the device's hostname
via standard DNS, as well as via multicast DNS (mDNS).
If the name is not resolvable via either DNS method, Windows 10 will fall back to establishing the
Miracast session using the standard Wi-Fi direct connection." | Format-RuleOutput
}

#
# Predefined rules for WiFi Direct
#

# NOTE: WlanSvc not enable by default in Windows Server 2019
New-NetFirewallRule -DisplayName "WLAN Service WFD ASP Coordination Protocol" `
	-Platform $Platform -PolicyStore $PolicyStore -Profile Private, Domain `
	-Service WlanSvc -Program $ServiceHost -Group $Group `
	-Enabled False -Action Allow -Direction $Direction -Protocol UDP `
	-LocalAddress Any -RemoteAddress LocalSubnet4 `
	-LocalPort 7325 -RemotePort 7325 `
	-LocalUser Any -EdgeTraversalPolicy Block `
	-InterfaceType $LocalInterface `
	-LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "WLAN Service to allow coordination protocol for WFD Service sessions.
Wi-Fi Direct (WFD) Protocol Specifies: Proximity Extensions, which enable two or more devices that
are running the same application to establish a direct connection without requiring an intermediary,
such as an infrastructure wireless access point (WAP).
For more info see description of WLAN AutoConfig service." | Format-RuleOutput

New-NetFirewallRule -DisplayName "WLAN Service WFD Driver-only" `
	-Platform $Platform -PolicyStore $PolicyStore -Profile Private, Domain `
	-Service Any -Program System -Group $Group `
	-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
	-LocalAddress Any -RemoteAddress LocalSubnet4 `
	-LocalPort Any -RemotePort Any `
	-LocalUser $LocalSystem -EdgeTraversalPolicy Block `
	-InterfaceType $LocalInterface `
	-Description "Rule for drivers to communicate over WFD, WFD Services kernel mode driver rule.
Wi-Fi Direct (WFD) Protocol Specifies: Proximity Extensions, which enable two or more devices that
are running the same application to establish a direct connection without requiring an intermediary,
such as an infrastructure wireless access point (WAP).
For more info see description of WLAN AutoConfig service." | Format-RuleOutput

New-NetFirewallRule -DisplayName "WLAN Service WFD Driver-only" `
	-Platform $Platform -PolicyStore $PolicyStore -Profile Private, Domain `
	-Service Any -Program System -Group $Group `
	-Enabled False -Action Allow -Direction $Direction -Protocol UDP `
	-LocalAddress Any -RemoteAddress LocalSubnet4 `
	-LocalPort Any -RemotePort Any `
	-LocalUser $LocalSystem -EdgeTraversalPolicy Block `
	-InterfaceType $LocalInterface `
	-LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Rule for drivers to communicate over WFD, WFD Services kernel mode driver rule.
Wi-Fi Direct (WFD) Protocol Specifies: Proximity Extensions, which enable two or more devices that
are running the same application to establish a direct connection without requiring an intermediary,
such as an infrastructure wireless access point (WAP).
For more info see description of WLAN AutoConfig service." | Format-RuleOutput

#
# Predefined rules for WiFi Direct Network Discovery
#

$Program = "%SystemRoot%\System32\dasHost.exe"
if ((Test-ExecutableFile $Program) -or $ForceLoad)
{
	# TODO: missing protocol and port for WiFi Direct Network Discovery
	New-NetFirewallRule -DisplayName "Wi-Fi Direct Network Discovery" `
		-Platform $Platform -PolicyStore $PolicyStore -Profile Public `
		-Service Any -Program $Program -Group $Group `
		-Enabled False -Action Allow -Direction $Direction -Protocol Any `
		-LocalAddress Any -RemoteAddress LocalSubnet4 `
		-LocalPort Any -RemotePort Any `
		-LocalUser $LocalService -EdgeTraversalPolicy Block `
		-InterfaceType Wired, Wireless  `
		-Description "Rule to discover WSD devices on Wi-Fi Direct networks.
Host enables pairing between the system and wired or wireless devices. This service is new since Windows 8.
Executable also known as Device Association Framework Provider Host" | Format-RuleOutput
}

New-NetFirewallRule -DisplayName "Wi-Fi Direct Scan Service" `
	-Platform $Platform -PolicyStore $PolicyStore -Profile Public `
	-Service stisvc -Program $ServiceHost -Group $Group `
	-Enabled False -Action Allow -Direction $Direction -Protocol Any `
	-LocalAddress Any -RemoteAddress LocalSubnet4 `
	-LocalPort Any -RemotePort Any `
	-LocalUser Any -EdgeTraversalPolicy Block `
	-InterfaceType Wired, Wireless  `
	-Description "Rule to use WSD scanners on Wi-Fi Direct networks.
Windows Image Acquisition (WIA) service provides image acquisition services for scanners and cameras." |
Format-RuleOutput

New-NetFirewallRule -DisplayName "Wi-Fi Direct Spooler Use" `
	-Platform $Platform -PolicyStore $PolicyStore -Profile Public `
	-Service Spooler -Program $ServiceHost -Group $Group `
	-Enabled False -Action Allow -Direction $Direction -Protocol Any `
	-LocalAddress Any -RemoteAddress LocalSubnet4 `
	-LocalPort Any -RemotePort Any `
	-LocalUser Any -EdgeTraversalPolicy Block `
	-InterfaceType Wired, Wireless  `
	-Description "Rule to use WSD printers on Wi-Fi Direct networks.
Print Spooler service spools print jobs and handles interaction with the printer.
If you turn off this service, you won't be able to print or see your printers." | Format-RuleOutput

#
# Predefined rules for Wireless portable devices
#

New-NetFirewallRule -DisplayName "Wireless portable devices (SSDP)" `
	-Platform $Platform -PolicyStore $PolicyStore -Profile Any `
	-Service SSDPSRV -Program $ServiceHost -Group $Group `
	-Enabled False -Action Allow -Direction $Direction -Protocol UDP `
	-LocalAddress Any -RemoteAddress LocalSubnet4 `
	-LocalPort 1900 -RemotePort Any `
	-LocalUser Any -EdgeTraversalPolicy Block `
	-InterfaceType $LocalInterface `
	-LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Wireless Portable Devices to allow use of the Simple Service Discovery Protocol." |
Format-RuleOutput

New-NetFirewallRule -DisplayName "Wireless portable devices (UPnP)" `
	-Platform $Platform -PolicyStore $PolicyStore -Profile Any `
	-Service Any -Program System -Group $Group `
	-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
	-LocalAddress Any -RemoteAddress LocalSubnet4 `
	-LocalPort 2869 -RemotePort Any `
	-LocalUser $LocalSystem -EdgeTraversalPolicy Block `
	-InterfaceType $LocalInterface `
	-Description "Wireless Portable Devices to allow use of Universal Plug and Play." | Format-RuleOutput

if ($UpdateGPO)
{
	Invoke-Process gpupdate.exe
	Disconnect-Computer -Domain $Domain
}

Update-Log
