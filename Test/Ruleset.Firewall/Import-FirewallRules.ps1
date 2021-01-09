
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020, 2021 metablaster zebal@protonmail.ch

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
Unit test for Import-FirewallRules

.DESCRIPTION
Test correctness of Import-FirewallRules function

.PARAMETER Force
If specified, no prompt to run script is shown.

.EXAMPLE
PS> .\Import-FirewallRules.ps1

.INPUTS
None. You cannot pipe objects to Import-FirewallRules.ps1

.OUTPUTS
None. Import-FirewallRules.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 $PSCmdlet
. $PSScriptRoot\ContextSetup.ps1
Initialize-Project -Strict

# User prompt
Update-Context $TestContext $ThisScript
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Unsafe -Force:$Force)) { exit }
#endregion

Enter-Test

if ($Force -or $PSCmdlet.ShouldContinue("Export firewall rules", "Accept slow unit test"))
{
	$Exports = "$ProjectRoot\Exports"

	# TODO: need to test failure cases, see also module todo's for more info
	# TODO: need to test store apps import for "Any" and "*" owner/package

	Start-Test "Import-FirewallRules -FileName GroupExport.csv"
	Import-FirewallRules -Folder $Exports -FileName "GroupExport.csv"

	Start-Test "Import-FirewallRules -FileName NamedExport1.csv"
	Import-FirewallRules -Folder $Exports -FileName "$Exports\NamedExport1.csv"

	Start-Test "Import-FirewallRules -JSON -FileName NamedExport2.json"
	Import-FirewallRules -JSON -Folder $Exports -FileName "$Exports\NamedExport2.json"

	Start-Test "Import-FirewallRules -FileName StoreAppExport.csv"
	$Result = Import-FirewallRules -Folder $Exports -FileName "StoreAppExport.csv"
	$Result

	Test-Output $Result -Command Import-FirewallRules
}

Update-Log
Exit-Test
