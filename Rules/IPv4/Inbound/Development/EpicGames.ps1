
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019-2021 metablaster zebal@protonmail.ch

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
Inbound firewall rules for EpicGames

.DESCRIPTION
Inbound firewall rules for Epic Games game engine

.EXAMPLE
PS> .\EpicGames.ps1

.INPUTS
None. You cannot pipe objects to EpicGames.ps1

.OUTPUTS
None. EpicGames.ps1 does not generate any output

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
$Group = "Development - Epic Games"
$LocalProfile = "Any"
$Accept = "Inbound rules for Epic Games launcher and engine will be loaded, recommended if Epic Games launcher and engine is installed to let it access to network"
$Deny = "Skip operation, inbound rules for Epic Games launcher and engine will not be loaded into firewall"

# User prompt
Update-Context "IPv$IPVersion" $Direction $Group
if (!(Approve-Execute -Accept $Accept -Deny $Deny)) { exit }
#endregion

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore

#
# Epic games installation directories
#
$EngineRoot = "%SystemDrive%\Users\$DefaultUser\source\repos\UnrealEngine\Engine"

# TODO: need to see listening ports

#
# Rules Epic games engine
#

# NOTE: default rule for crash report and swarm is edge traversal: defer to user
# for defer to user, interface and address (and probably ports too) must not be specified, platform must not be defined
# this does not suit our interests so removed

# Test if installation exists on system
if ((Confirm-Installation "UnrealEngine" ([ref] $EngineRoot)) -or $ForceLoad)
{
	$Program = "$EngineRoot\Binaries\Win64\CrashReportClientEditor-Win64-Development.exe"
	Test-ExecutableFile $Program
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Unreal Engine - CrashReportClientEditor" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $LocalProfile -InterfaceType Any `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Any -LocalPort Any -RemotePort Any `
		-EdgeTraversalPolicy Block -LocalUser $UsersGroupSDDL `
		-Description "" | Format-Output

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Unreal Engine - CrashReportClientEditor" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $LocalProfile -InterfaceType Any `
		-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Any -LocalPort Any -RemotePort Any `
		-EdgeTraversalPolicy Block -LocalUser $UsersGroupSDDL -LocalOnlyMapping $false -LooseSourceMapping $false `
		-Description "" | Format-Output

	$Program = "$EngineRoot\Binaries\DotNET\SwarmAgent.exe"
	Test-ExecutableFile $Program
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Unreal Engine - SwarmAgent" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $LocalProfile -InterfaceType Any `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort Any -RemotePort Any `
		-EdgeTraversalPolicy Block -LocalUser $UsersGroupSDDL `
		-Description "Swarm agent is used for build farm." | Format-Output

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Unreal Engine - SwarmAgent" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $LocalProfile -InterfaceType Any `
		-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort Any -RemotePort Any `
		-EdgeTraversalPolicy Block -LocalUser $UsersGroupSDDL -LocalOnlyMapping $false -LooseSourceMapping $false `
		-Description "Swarm agent is used for build farm." | Format-Output

	$Program = "$EngineRoot\Binaries\Win64\UnrealInsights.exe"
	Test-ExecutableFile $Program
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Unreal Engine - UnrealInsights" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $LocalProfile -InterfaceType $DefaultInterface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort Any -RemotePort Any `
		-EdgeTraversalPolicy Block -LocalUser $UsersGroupSDDL `
		-Description "" | Format-Output

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Unreal Engine - UnrealInsights" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $LocalProfile -InterfaceType $DefaultInterface `
		-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort Any -RemotePort Any `
		-EdgeTraversalPolicy Block -LocalUser $UsersGroupSDDL -LocalOnlyMapping $false -LooseSourceMapping $false `
		-Description "" | Format-Output
}

Update-Log
