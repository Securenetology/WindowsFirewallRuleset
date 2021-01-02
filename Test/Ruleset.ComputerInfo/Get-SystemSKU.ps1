
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
Unit test for Get-SystemSKU

.DESCRIPTION
Unit test for Get-SystemSKU

.EXAMPLE
PS> .\Get-SystemSKU.ps1

.INPUTS
None. You cannot pipe objects to Get-SystemSKU.ps1

.OUTPUTS
None. Get-SystemSKU.ps1 does not generate any output

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

# User prompt
Update-Context $TestContext $ThisScript
if (!(Approve-Execute -Accept $Accept -Deny $Deny)) { exit }
#endregion

Enter-Test

Start-Test "Get-SystemSKU -ComputerName $([System.Environment]::MachineName)"
Get-SystemSKU -ComputerName $([System.Environment]::MachineName) | Format-Table

Start-Test "Get-SystemSKU -SKU 4"
$Result = Get-SystemSKU -SKU 48
$Result | Format-Table

Start-Test "34 | Get-SystemSKU"
34 | Get-SystemSKU | Format-Table

Start-Test '@($([System.Environment]::MachineName), "INVALID_COMPUTER") | Get-SystemSKU FAILURE TEST'
@($([System.Environment]::MachineName), "INVALID_COMPUTER") | Get-SystemSKU -ErrorAction SilentlyContinue | Format-Table

Start-Test '$Result = @($([System.Environment]::MachineName), "INVALID_COMPUTER") | Get-SystemSKU FAILURE TEST'
@($([System.Environment]::MachineName), "INVALID_COMPUTER") | Get-SystemSKU -ErrorAction SilentlyContinue | Format-Table

Start-Test 'Get-SystemSKU -ComputerName @($([System.Environment]::MachineName), "INVALID_COMPUTER") FAILURE TEST'
Get-SystemSKU -ComputerName @($([System.Environment]::MachineName), "INVALID_COMPUTER") -ErrorAction SilentlyContinue | Format-Table

try
{
	Start-Test "Get-SystemSKU -SKU 4 -ComputerName $([System.Environment]::MachineName)"
	Get-SystemSKU -SKU 4 -ComputerName $([System.Environment]::MachineName) -ErrorAction Stop
}
catch
{
	Write-Information -Tags "Test" -MessageData "Failure test success"
}

Test-Output $Result -Command Get-SystemSKU

Update-Log
Exit-Test
