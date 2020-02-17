
<#
MIT License

Project: "Windows Firewall Ruleset" serves to manage firewall on Windows systems
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

. $PSScriptRoot\..\..\..\..\Config\ProjectSettings.ps1

# Check requirements for this project
Import-Module -Name $RepoDir\Modules\System
Test-SystemRequirements

# Includes
. $PSScriptRoot\..\DirectionSetup.ps1
. $PSScriptRoot\..\..\IPSetup.ps1
Import-Module -Name $RepoDir\Modules\UserInfo
Import-Module -Name $RepoDir\Modules\ProgramInfo
Import-Module -Name $RepoDir\Modules\FirewallModule

#
# Setup local variables:
#
$Group = "Games - PathOfExile"
$Profile = "Private, Public"

# Ask user if he wants to load these rules
Update-Context "IPv$IPVersion" $Direction $Group
if (!(Approve-Execute)) { exit }

#
# PathOfExile installation directories
#
$PathOfExileRoot = "%ProgramFiles(x86)%\Steam\steamapps\common\Path of Exile"

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction SilentlyContinue

#
# Rules for TargetProgram
#

# Test if installation exists on system
if ((Test-Installation "PathOfExile" ([ref]$PathOfExileRoot)) -or $Force)
{
	$Program = "$PathOfExileRoot\PathOfExile_x64Steam.exe"
	Test-File $Program
	New-NetFirewallRule -Platform $Platform `
	-DisplayName "Path of exile" -Service Any -Program $Program `
	-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 6112, 20481 `
	-LocalUser $UserAccountsSDDL `
	-Description "Needed for online gaming" | Format-Output
}
