
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019-2022 metablaster zebal@protonmail.ch

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
Inbound firewall rules for MicrosoftOffice

.DESCRIPTION
Inbound firewall rules for Microsoft Office software suite

.PARAMETER Trusted
If specified, rules will be loaded for executables with missing or invalid digital signature.
By default an error is generated and rule isn't loaded.

.PARAMETER Interactive
If program installation directory is not found, script will ask user to
specify program installation location.

.PARAMETER Quiet
If specified, it suppresses warning, error or informationall messages if user specified or default
program path does not exist or if it's of an invalid syntax needed for firewall.

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\MicrosoftOffice.ps1

.INPUTS
None. You cannot pipe objects to MicrosoftOffice.ps1

.OUTPUTS
None. MicrosoftOffice.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
	[Parameter()]
	[switch] $Trusted,

	[Parameter()]
	[switch] $Interactive,

	[Parameter()]
	[switch] $Quiet,

	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\..\..\..\Config\ProjectSettings.ps1 $PSCmdlet
. $PSScriptRoot\..\..\DirectionSetup.ps1

Initialize-Project
Import-Module -Name Ruleset.UserInfo

# Setup local variables
$Group = "Microsoft Office"
$Accept = "Inbound rules for Microsoft Office will be loaded, recommended if Microsoft Office is installed to let it access to network"
$Deny = "Skip operation, inbound rules for Microsoft Office will not be loaded into firewall"

if (!(Approve-Execute -Accept $Accept -Deny $Deny -ContextLeaf $Group -Force:$Force)) { exit }
$PSDefaultParameterValues = @{
	"Confirm-Installation:Quiet" = $Quiet
	"Confirm-Installation:Interactive" = $Interactive
	"Confirm-Installation:Session" = $SessionInstance
	"Confirm-Installation:CimSession" = $CimServer
	"Test-ExecutableFile:Quiet" = $Quiet
	"Test-ExecutableFile:Force" = $Trusted -or $SkipSignatureCheck
	"Test-ExecutableFile:Session" = $SessionInstance
}
#endregion

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore

#
# Office installation directories
#
$OfficeRoot = "%ProgramFiles%\Microsoft Office\root\Office16"

#
# Microsoft office rules
#

# Test if installation exists on system
if ((Confirm-Installation "MicrosoftOffice" ([ref] $OfficeRoot)) -or $ForceLoad)
{
	$Program = "$OfficeRoot\OUTLOOK.EXE"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "Outlook" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol UDP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort 6004 -RemotePort Any `
			-LocalUser $UsersGroupSDDL -EdgeTraversalPolicy Block `
			-InterfaceType $DefaultInterface `
			-LocalOnlyMapping $false -LooseSourceMapping $false `
			-Description "" | Format-RuleOutput
	}

	# TODO: Skype for business has complex port requirements, see:
	# https://docs.pexip.com/sfb/ports.htm
	# https://docs.microsoft.com/en-us/skypeforbusiness/plan-your-deployment/network-requirements/ports-and-protocols
	$Program = "$OfficeRoot\lync.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "Skype for business" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort Any `
			-LocalUser $UsersGroupSDDL -EdgeTraversalPolicy Block `
			-InterfaceType $DefaultInterface `
			-Description "Skype for business, previously lync." | Format-RuleOutput

		New-NetFirewallRule -DisplayName "Skype for business" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol UDP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort Any `
			-LocalUser $UsersGroupSDDL -EdgeTraversalPolicy Block `
			-InterfaceType $DefaultInterface `
			-LocalOnlyMapping $false -LooseSourceMapping $false `
			-Description "Skype for business, previously lync." | Format-RuleOutput
	}

	$Program = "$OfficeRoot\UcMapi.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "UcMapi" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort Any `
			-LocalUser $UsersGroupSDDL -EdgeTraversalPolicy Block `
			-InterfaceType $DefaultInterface `
			-Description "Unified Communications Messaging Application Programming Interface" | Format-RuleOutput

		New-NetFirewallRule -DisplayName "UcMapi" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol UDP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort Any `
			-LocalUser $UsersGroupSDDL -EdgeTraversalPolicy Block `
			-InterfaceType $DefaultInterface `
			-LocalOnlyMapping $false -LooseSourceMapping $false `
			-Description "Unified Communications Messaging Application Programming Interface" | Format-RuleOutput
	}
}

if ($UpdateGPO)
{
	Invoke-Process gpupdate.exe -NoNewWindow -ArgumentList "/target:computer"
	Disconnect-Computer -Domain $PolicyStore
}

Update-Log
