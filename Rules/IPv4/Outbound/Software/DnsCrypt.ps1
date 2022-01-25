
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
Outbound firewall rules for DnsCrypt

.DESCRIPTION
Outbound firewall rules for dnscrypt-proxy and Simple DnsCrypt

.PARAMETER Trusted
If specified, rules will be loaded for executables with missing or invalid digital signature.
By default an error is generated and rule isn't loaded.

.PARAMETER Quiet
If specified, it won't ask user to specify program location if not found,
instead only a warning is shown.

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\DnsCrypt.ps1

.INPUTS
None. You cannot pipe objects to DnsCrypt.ps1

.OUTPUTS
None. DnsCrypt.ps1 does not generate any output

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
	[switch] $Quiet,

	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\..\..\Config\ProjectSettings.ps1 $PSCmdlet
. $PSScriptRoot\..\DirectionSetup.ps1

Initialize-Project -Strict
Import-Module -Name Ruleset.UserInfo

# Setup local variables
$Group = "Software - DnsCrypt"
$Accept = "Outbound rules for DnsCrypt software will be loaded, recommended if DnsCrypt software is installed to let it access to network"
$Deny = "Skip operation, outbound rules for DnsCrypt software will not be loaded into firewall"

if (!(Approve-Execute -Accept $Accept -Deny $Deny -ContextLeaf $Group -Force:$Force)) { exit }
$PSDefaultParameterValues["Confirm-Installation:Quiet"] = $Quiet
$PSDefaultParameterValues["Test-ExecutableFile:Force"] = $Trusted -or $SkipSignatureCheck
#endregion

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore

#
# DnsCrypt installation directories
#
$DnsCryptRoot = "%ProgramFiles%\bitbeans\Simple DNSCrypt x64"

#
# DnsCrypt rules
# TODO: remote servers from file, explicit TCP or UDP
# HACK: If localhost (DNSCrypt) is the only DNS server (no secondary DNS) then network status will be
# "No internet access" even though internet works just fine
# TODO: Add rule for "Global resolver", dnscrypt-proxy acting as server
# https://www.cloudflare.com/learning/dns/dns-over-tls/
#

# Test if installation exists on system
if ((Confirm-Installation "DnsCrypt" ([ref] $DnsCryptRoot)) -or $ForceLoad)
{
	# NOTE: Port 53 (unencrypted) is required for fallback resolver
	# NOTE: Previously it was -Service dnscrypt-proxy, but now it's NT AUTHORITY SYSTEM
	$Program = "$DnsCryptRoot\dnscrypt-proxy\dnscrypt-proxy.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "dnscrypt-proxy" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled True -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 53, 443, 853 `
			-LocalUser $LocalSystem `
			-InterfaceType $DefaultInterface `
			-Description "DNSCrypt is a protocol that authenticates communications between a DNS client
and a DNS resolver. It prevents DNS spoofing.
It uses cryptographic signatures to verify that responses originate from the chosen DNS resolver
and haven't been tampered with.
This rule applies to both TLS and HTTPS encrypted DNS using dnscrypt-proxy." |
		Format-RuleOutput

		# TODO: see if LooseSourceMapping is needed
		New-NetFirewallRule -DisplayName "dnscrypt-proxy" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled True -Action Allow -Direction $Direction -Protocol UDP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 53, 443, 853 `
			-LocalUser $LocalSystem `
			-LocalOnlyMapping $false -LooseSourceMapping $false `
			-InterfaceType $DefaultInterface `
			-Description "DNSCrypt is a protocol that authenticates communications between a DNS client
and a DNS resolver. It prevents DNS spoofing.
It uses cryptographic signatures to verify that responses originate from the chosen DNS resolver and
haven't been tampered with.
This rule applies to both TLS and HTTPS encrypted DNS using dnscrypt-proxy." |
		Format-RuleOutput
	}

	$Program = "$DnsCryptRoot\SimpleDnsCrypt.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "Simple DNS Crypt" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled True -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 80, 443 `
			-LocalUser $AdminGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "Simple DNS Crypt update check on startup" |
		Format-RuleOutput
	}
}

if ($UpdateGPO)
{
	Invoke-Process gpupdate.exe -NoNewWindow -ArgumentList "/target:computer"
}

Update-Log
