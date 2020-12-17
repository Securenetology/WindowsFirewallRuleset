
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

<#
.SYNOPSIS
Outbound firewall rules for Path Of Exile

.DESCRIPTION
Outbound firewall rules for Path Of Exile MMO game

.EXAMPLE
PS> .\PathOfExile.ps1

.INPUTS
None. You cannot pipe objects to PathOfExile.ps1

.OUTPUTS
None. PathOfExile.ps1 does not generate any output

.NOTES
None.
#>

#region Initialization
#Requires -RunAsAdministrator
. $PSScriptRoot\..\..\..\..\Config\ProjectSettings.ps1

# Check requirements
Initialize-Project -Abort

# Imports
. $PSScriptRoot\..\DirectionSetup.ps1
Import-Module -Name Ruleset.UserInfo

# Setup local variables
$Group = "Games - Path of Exile"
$Accept = "Outbound rules for Path of Exile game will be loaded, recommended if Path of Exile game is installed to let it access to network"
$Deny = "Skip operation, outbound rules for Path of Exile game will not be loaded into firewall"

# User prompt
Update-Context "IPv$IPVersion" $Direction $Group
if (!(Approve-Execute -Accept $Accept -Deny $Deny)) { exit }
#endregion

#
# Path Of Exile installation directories
#
$PathOfExileRoot = "%ProgramFiles(x86)%\Steam\steamapps\common\Path of Exile"

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore

#
# Rules for Path Of Exile
#

# Test if installation exists on system
if ((Test-Installation "PathOfExile" ([ref] $PathOfExileRoot)) -or $ForceLoad)
{
	$Program = "$PathOfExileRoot\PathOfExile_x64Steam.exe"
	Test-File $Program
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Path of exile" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $DefaultProfile -InterfaceType $DefaultInterface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 6112, 20481 `
		-LocalUser $UsersGroupSDDL `
		-Description "Needed for online gaming" | Format-Output
}

Update-Log
