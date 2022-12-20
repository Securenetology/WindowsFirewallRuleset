
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
Unit test for Get-UserSoftware

.DESCRIPTION
Test correctness of Get-UserSoftware function

.PARAMETER Domain
If specified, only remoting tests against specified computer name are performed

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\Get-UserSoftware.ps1

.INPUTS
None. You cannot pipe objects to Get-UserSoftware.ps1

.OUTPUTS
None. Get-UserSoftware.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
	[Parameter()]
	[Alias("ComputerName", "CN")]
	[string] $Domain = [System.Environment]::MachineName,

	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 $PSCmdlet -Domain $Domain
. $PSScriptRoot\..\ContextSetup.ps1

Initialize-Project
Import-Module -Name Ruleset.UserInfo
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Force:$Force)) { exit }
#endregion

Enter-Test "Get-UserSoftware"
if ($Domain -ne [System.Environment]::MachineName)
{
	Start-Test "Get remote user" -Command Get-GroupPrincipal
	$Users = Get-GroupPrincipal -Group Users -CimSession $CimServer
	$Users

	Start-Test "Remote default $($Users[0].User)"
	Get-UserSoftware -User $Users[0].User -CimSession $CimServer -Session $SessionInstance
}
else
{
	# NOTE: Invoke access denied to registry if test run as standard user
	$UserGroup = @("Users", "Administrators")

	Start-Test "$UserGroup" -Command "Get-GroupPrincipal"
	$Principals = Get-GroupPrincipal $UserGroup
	# TODO: This Format-Table won't be needed once we have consistent outputs, formats and better pipelines
	$Principals | Format-Table

	foreach ($Principal in $Principals)
	{
		Start-Test "$($Principal.User)"
		$Result = Get-UserSoftware $Principal.User
		$Result
	}

	# NOTE: Test won't work unless there are programs installed in user profile
	Test-Output $Result -Command Get-UserSoftware -Force
}

Update-Log
Exit-Test
