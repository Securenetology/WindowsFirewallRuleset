
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
Unit test for Confirm-Installation

.DESCRIPTION
Unit test for Confirm-Installation

.EXAMPLE
PS> .\Confirm-Installation.ps1

.INPUTS
None. You cannot pipe objects to Confirm-Installation.ps1

.OUTPUTS
None. Confirm-Installation.ps1 does not generate any output

.NOTES
None.
#>

#region Initialization
#Requires -RunAsAdministrator
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value ((Get-Item $PSCommandPath).Basename)

# Check requirements
Initialize-Project -Abort

# Imports
. $PSScriptRoot\ContextSetup.ps1

# User prompt
Update-Context $TestContext $ThisScript
if (!(Approve-Execute -Accept $Accept -Deny $Deny)) { exit }
#endregion

Enter-Test

$VSCodeRoot = ""
$OneDrive = "unknown"
$OfficeRoot = "%ProgramFiles(x866666)%\Microsoft Office\root\Office16"
$TestBadVariable = "%UserProfile%\crazyFolder"
$TestBadVariable2 = "%UserProfile%\crazyFolder"

Start-Test "Confirm-Installation 'VSCode' $VSCodeRoot"
$Result = Confirm-Installation "VSCode" ([ref] $VSCodeRoot)
$Result

Start-Test "Confirm-Installation 'OneDrive' $OneDrive"
Confirm-Installation "OneDrive" ([ref] $OneDrive)

Start-Test "Confirm-Installation 'MicrosoftOffice' $OfficeRoot"
Confirm-Installation "MicrosoftOffice" ([ref] $OfficeRoot)

Start-Test "Confirm-Installation 'VisualStudio' $TestBadVariable"
Confirm-Installation "VisualStudio" ([ref] $TestBadVariable)

Start-Test "Confirm-Installation 'FailureTest' $TestBadVariable2"
Confirm-Installation "FailureTest" ([ref] $TestBadVariable2)

Test-Output $Result -Command Confirm-Installation

Update-Log
Exit-Test