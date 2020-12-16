
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
Unit test for project settings

.DESCRIPTION
Unit test to test global variables and preferences set in Config\ProjectSettings.ps1

.EXAMPLE
PS> .\TestProjectSettings.ps1

.INPUTS
None. You cannot pipe objects to TestProjectSettings.ps1

.OUTPUTS
None. TestProjectSettings.ps1 does not generate any output

.NOTES
None.
#>

#region Initialization
. $PSScriptRoot\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value ((Get-Item $PSCommandPath).Basename)

# Imports
. $PSScriptRoot\ContextSetup.ps1

# Check requirements
Initialize-Project -Abort

# User prompt
Update-Context $TestContext $ThisScript
if (!(Approve-Execute -Accept $Accept -Deny $Deny)) { exit }
#endregion

Enter-Test

# Test module preferences to verify preferences are set to expected values,
# In addition show session preferences to verify difference.
Start-Test "Script preferences"

if ($DebugPreference -eq "Continue")
{
	$DebugPreference = "SilentlyContinue"
}
else
{
	$DebugPreference = "Continue"
}

Write-Debug -Message "[$ThisScript] DebugPreference before: $DebugPreference" # -Debug
. $PSScriptRoot\..\Config\ProjectSettings.ps1 -ShowPreference
Write-Debug -Message "[$ThisScript] DebugPreference after: $DebugPreference" # -Debug

# NOTE: For this test to show correct result $DebugPreference in ProjectSettings must be "Continue"
Start-Test "Script module preferences"
$TestModule = New-Module -Name Dynamic.TestPreference -ErrorAction Stop -ScriptBlock {
	Set-Variable -Name ThisModule -Scope Script -Option ReadOnly -Force -Value "Dynamic.TestPreference"
	Write-Debug -Message "[Dynamic.TestPreference] DebugPreference before: $DebugPreference" # -Debug

	. $PSScriptRoot\..\Config\ProjectSettings.ps1 -ShowPreference -InModule
	. $PSScriptRoot\..\Modules\ModulePreferences.ps1

	Write-Debug -Message "[Dynamic.TestPreference] DebugPreference after: $DebugPreference" # -Debug
} | Import-Module -Scope Global -PassThru

Start-Test "Script module no exports"
$ExportCount = ($TestModule | Select-Object -ExpandProperty ExportedCommands | Measure-Object).Count
if ($ExportCount -gt 0)
{
	Write-Error -Category InvalidResult -TargetObject $TestModule `
		-Message "Nothing should be exported from this module"

	Write-Information -Tags "Test" -MessageData "INFO: $ExportCount exports: $($TestModule | Select-Object -ExpandProperty ExportedCommands)"
}

Remove-Module -Name Dynamic.TestPreference -ErrorAction Stop

Start-Test "Don't show preferences"
. $PSScriptRoot\..\Config\ProjectSettings.ps1
. $PSScriptRoot\..\Config\ProjectSettings.ps1 -ShowPreference:$false

$TestModule = New-Module -Name Dynamic.TestPreference -ErrorAction Stop -ScriptBlock {
	Set-Variable -Name ThisModule -Scope Script -Option ReadOnly -Force -Value "Dynamic.TestPreference"

	. $PSScriptRoot\..\Config\ProjectSettings.ps1 -InModule
	. $PSScriptRoot\..\Modules\ModulePreferences.ps1

	. $PSScriptRoot\..\Config\ProjectSettings.ps1 -InModule -ShowPreference:$false
	. $PSScriptRoot\..\Modules\ModulePreferences.ps1
} | Import-Module -Scope Global -PassThru

Remove-Module -Name Dynamic.TestPreference -ErrorAction Stop

Start-Test "Bad call"
& $PSScriptRoot\..\Config\ProjectSettings.ps1 -EV ErrorCapture -IV InfoCapture -INFA SilentlyContinue -EA SilentlyContinue
Write-Warning -Message "Failure test: $ErrorCapture"
Write-Warning -Message "Failure test: $InfoCapture"

Update-Log
Exit-Test
