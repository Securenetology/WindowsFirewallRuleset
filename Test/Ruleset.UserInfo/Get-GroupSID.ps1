
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020 metablaster zebal@protonmail.ch

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
Unit test for Get-GroupSID

.DESCRIPTION
Unit test for Get-GroupSID

.EXAMPLE
PS> .\Get-GroupSID.ps1

.INPUTS
None. You cannot pipe objects to Get-GroupSID.ps1

.OUTPUTS
None. Get-GroupSID.ps1 does not generate any output

.NOTES
None.
#>

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value ((Get-Item $PSCommandPath).Basename)

# Check requirements
Initialize-Project -Abort

# Imports
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name Ruleset.UserInfo

# User prompt
Update-Context $TestContext $ThisScript
if (!(Approve-Execute -Accept $Accept -Deny $Deny)) { exit }
#endregion

Enter-Test

#
# Test single group
#

[string] $SingleGroup = "Users"
Start-Test "Get-GroupSID $SingleGroup"
$GroupsTest = Get-GroupSID $SingleGroup
$GroupsTest

Test-Output $GroupsTest -Command Get-GroupSID

Start-Test "Get-GroupSID 'Users' -CIM"
$GroupsTest = Get-GroupSID $SingleGroup -CIM
$GroupsTest

#
# Test array of groups
#

[string[]] $GroupArray = @("Users", "Hyper-V Administrators")

Start-Test "Get-GroupSID $GroupArray"
$GroupsTest = Get-GroupSID $GroupArray
$GroupsTest

Test-Output $GroupsTest -Command Get-GroupSID

Start-Test "Get-GroupSID $GroupArray -CIM"
$GroupsTest = Get-GroupSID $GroupArray -CIM
$GroupsTest

#
# Test pipeline
#

$GroupArray = @("Users", "Administrators")

Start-Test "$GroupArray | Get-GroupSID"
$GroupArray | Get-GroupSID

Start-Test "$GroupArray | Get-GroupSID -CIM"
$GroupArray | Get-GroupSID -CIM

#
# Test failure
#

Start-Test "FAILURE TEST NO CIM: Get-GroupSID @('Users', 'Hyper-V Administrators')"
Get-GroupSID "Users", 'Hyper-V Administrators' -Domain "CRAZYMACHINE" -ErrorAction SilentlyContinue

Start-Test "FAILURE TEST CONTACT: Get-GroupSID @('Users', 'Hyper-V Administrators')"
Get-GroupSID "Users", 'Hyper-V Administrators' -Domain "CRAZYMACHINE" -CIM -ErrorAction SilentlyContinue

Update-Log
Exit-Test
