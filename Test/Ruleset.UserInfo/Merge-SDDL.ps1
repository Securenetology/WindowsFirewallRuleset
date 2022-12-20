
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020-2022 metablaster zebal@protonmail.ch

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
Unit test for Merge-SDDL

.DESCRIPTION
Test correctness of Merge-SDDL function

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\Merge-SDDL.ps1

.INPUTS
None. You cannot pipe objects to Merge-SDDL.ps1

.OUTPUTS
None. Merge-SDDL.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 $PSCmdlet
. $PSScriptRoot\..\ContextSetup.ps1

Initialize-Project
Import-Module -Name Ruleset.UserInfo
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Force:$Force)) { exit }
#endregion

Enter-Test "Merge-SDDL"

[string[]] $Users = @($TestUser)
[string] $Domain = [System.Environment]::MachineName
[string[]] $Groups = @("Users", "Administrators")

Start-Test "Get-SDDL -User $Users -Group $Groups -Domain $Domain"
$TestUsersSDDL = Get-SDDL -User $Users -Group $Groups -Domain $Domain -Merge
$TestUsersSDDL

Start-Test "Get-SDDL -Domain 'NT AUTHORITY' -User 'SYSTEM', 'USER MODE DRIVERS'"
$NewSDDL = Get-SDDL -Domain "NT AUTHORITY" -User "SYSTEM", "USER MODE DRIVERS" -Merge
$NewSDDL

Start-Test "default"
$TestSDDL = $TestUsersSDDL
$Result = Merge-SDDL ([ref] $TestSDDL) -From $NewSDDL
$Result
$TestSDDL

Start-Test "Unique"
$TestSDDL = $TestUsersSDDL
$Result = Merge-SDDL ([ref] $TestSDDL) -From $TestSDDL -Unique
$Result
$TestSDDL

Test-Output $Result -Command Merge-SDDL

Update-Log
Exit-Test
