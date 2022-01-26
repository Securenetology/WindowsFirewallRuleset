
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
Outbound firewall rules for MSYS2

.DESCRIPTION
Outbound firewall rules for MSYS2 software suite

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
PS> .\MSYS2.ps1

.INPUTS
None. You cannot pipe objects to MSYS2.ps1

.OUTPUTS
None. MSYS2.ps1 does not generate any output

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
. $PSScriptRoot\..\..\..\..\Config\ProjectSettings.ps1 $PSCmdlet
. $PSScriptRoot\..\DirectionSetup.ps1

Initialize-Project -Strict
Import-Module -Name Ruleset.UserInfo

# Setup local variables
$Group = "Development - MSYS2"
$Accept = "Outbound rules for MSYS2 software will be loaded, recommended if MSYS2 software is installed to let it access to network"
$Deny = "Skip operation, outbound rules for MSYS2 software will not be loaded into firewall"

if (!(Approve-Execute -Accept $Accept -Deny $Deny -ContextLeaf $Group -Force:$Force)) { exit }
$PSDefaultParameterValues["Confirm-Installation:Quiet"] = $Quiet
$PSDefaultParameterValues["Confirm-Installation:Interactive"] = $Interactive
$PSDefaultParameterValues["Test-ExecutableFile:Quiet"] = $Quiet
$PSDefaultParameterValues["Test-ExecutableFile:Force"] = $Trusted -or $SkipSignatureCheck
#endregion

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore

#
# Steam installation directories
#
$MSYS2Root = "%SystemRoot%\dev\msys64"

#
# Rules for Steam client
#

# Test if installation exists on system
if ((Confirm-Installation "MSYS2" ([ref] $MSYS2Root)) -or $ForceLoad)
{
	$Program = "$MSYS2Root\usr\bin\curl.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "MSYS2 - curl" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 21, 80 `
			-LocalUser $UsersGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "download with curl in MSYS2 shell.
curl is a commandline tool to transfer data from or to a server,
using one of the supported protocols:
(DICT, FILE, FTP, FTPS, GOPHER, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, MQTT, POP3, POP3S, RTMP,
RTMPS, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, TELNET and TFTP)" |
		Format-RuleOutput
	}

	$Program = "$MSYS2Root\usr\bin\git.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "MSYS2 - git protocol" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 9418 `
			-LocalUser $UsersGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "git access over git:// protocol" | Format-RuleOutput
	}

	$Program = "$MSYS2Root\usr\bin\git-remote-https.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "MSYS2 - git-remote-https" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 443 `
			-LocalUser $UsersGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "git over HTTPS in MSYS2 shell" | Format-RuleOutput
	}

	$Program = "$MSYS2Root\usr\bin\ssh.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "MSYS2 - git SSH" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 22 `
			-LocalUser $UsersGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "git over SSH in MSYS2 shell" | Format-RuleOutput
	}

	$Program = "$MSYS2Root\mingw64\bin\glade.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "MSYS2 - glade help" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 80, 443 `
			-LocalUser $UsersGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "Get online help for glade" | Format-RuleOutput
	}

	$Program = "$MSYS2Root\usr\bin\pacman.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "MSYS2 - pacman" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled True -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 80, 443 `
			-LocalUser $UsersGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "pacman package manager in MSYS2 shell" | Format-RuleOutput
	}

	$Program = "$MSYS2Root\usr\bin\pacman.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "MSYS2 - wget" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled False -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 80 `
			-LocalUser $UsersGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "HTTP download manager" | Format-RuleOutput
	}
}

if ($UpdateGPO)
{
	Invoke-Process gpupdate.exe -NoNewWindow -ArgumentList "/target:computer"
}

Update-Log
