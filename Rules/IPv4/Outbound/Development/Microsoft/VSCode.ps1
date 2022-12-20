
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
Outbound firewall rules for VSCode

.DESCRIPTION
Outbound firewall rules for Visual Studio Code

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
PS> .\VSCode.ps1

.INPUTS
None. You cannot pipe objects to VSCode.ps1

.OUTPUTS
None. VSCode.ps1 does not generate any output

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
$Group = "Development - Microsoft VSCode"
$ExtensionsGroup = "$Group extensions"
$Accept = "Outbound rules for Microsoft VSCode will be loaded, recommended if Microsoft VSCode is installed to let it access to network"
$Deny = "Skip operation, outbound rules for Microsoft VSCode will not be loaded into firewall"

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

#
# Visual Studio Code installation directories
#
$VSCodeRoot = "%ProgramFiles%\Microsoft VS Code"

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $ExtensionsGroup -Direction $Direction -ErrorAction Ignore

#
# Rules for Visual Studio Code
#

# Test if installation exists on system
if ((Confirm-Installation "VSCode" ([ref] $VSCodeRoot)) -or $ForceLoad)
{
	$Program = "$VSCodeRoot\Code.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -DisplayName "Visual Studio Code" `
			-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
			-Service Any -Program $Program -Group $Group `
			-Enabled True -Action Allow -Direction $Direction -Protocol TCP `
			-LocalAddress Any -RemoteAddress Internet4 `
			-LocalPort Any -RemotePort 80, 443 `
			-LocalUser $UsersGroupSDDL `
			-InterfaceType $DefaultInterface `
			-Description "Visual Studio Code check for updates, extensions download, telemetry and settings sync." |
		Format-RuleOutput
	}

	# VSCode extensions which require internet access
	foreach ($Principal in (Get-GroupPrincipal -Group $DefaultGroup -CimSession $CimServer))
	{
		$User = $Principal.User
		$ExtensionDirectory = Get-ChildItem -Path "C:\Users\$User\.vscode\extensions\redhat.vscode-xml-*" |
		Select-Object -ExpandProperty Name
		$Program = "%SystemDrive%\Users\$User\.vscode\extensions\$ExtensionDirectory\server\lemminx-win32.exe"

		# NOTE: Test-Path because it's very likely extension isn't installed by every user
		if ((Test-ExecutableFile $Program) -or $ForceLoad)
		{
			New-NetFirewallRule -DisplayName "Red Hat XML extension" `
				-Platform $Platform -PolicyStore $PolicyStore -Profile $DefaultProfile `
				-Service Any -Program $Program -Group $ExtensionsGroup `
				-Enabled True -Action Allow -Direction $Direction -Protocol TCP `
				-LocalAddress Any -RemoteAddress Internet4 `
				-LocalPort Any -RemotePort 443 `
				-LocalUser (Get-SDDL -User $User) `
				-InterfaceType $DefaultInterface `
				-Description "Visual Studio Code rule for $ExtensionDirectory extension" |
			Format-RuleOutput
		}
	}
}

if ($UpdateGPO)
{
	Invoke-Process gpupdate.exe -NoNewWindow -ArgumentList "/target:computer"
	Disconnect-Computer -Domain $PolicyStore
}

Update-Log
