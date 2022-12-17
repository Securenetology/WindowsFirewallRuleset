
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
Unit test for Edit-Table

.DESCRIPTION
Test correctness of Edit-Table function

.PARAMETER Domain
If specified, only remoting tests against specified computer name are performed

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\Edit-Table.ps1

.INPUTS
None. You cannot pipe objects to Edit-Table.ps1

.OUTPUTS
None. Edit-Table.ps1 does not generate any output

.NOTES
TODO: can we use Requires -PSSnapin here for Initialize-Table?
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

Initialize-Project -Strict
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Force:$Force)) { exit }
#endregion

Enter-Test "Edit-Table" #-Private

if (!(Get-Command -Name Initialize-Table -ErrorAction Ignore) -or
	!(Get-Command -Name Edit-Table -ErrorAction Ignore) -or
	!(Get-Variable -Name InstallTable -ErrorAction Ignore))
{
	Write-Error -Category NotEnabled -Message "This unit test requires export of privave functions and variables"
	Update-Log
	Exit-Test
	return
}

$RemoteParams = @{
	CimSession = $CimServer
	Session = $SessionInstance
}

if ($Domain -ne [System.Environment]::MachineName)
{
	$RemoteParams.Domain = $Domain
}

Start-Test "Good system path"
Initialize-Table
Edit-Table "%SystemRoot%\System32\WindowsPowerShell\v1.0" @RemoteParams
Get-Variable -Name InstallTable -ErrorAction Ignore |
Select-Object -ExpandProperty Value | Format-Table -AutoSize

Start-Test "Bad system path"
Initialize-Table
Edit-Table "%ProgramFiles(x86)%\Microsoft Help Viewer\v2.3345345" @RemoteParams
Get-Variable -Name InstallTable -ErrorAction Ignore |
Select-Object -ExpandProperty Value | Format-Table -AutoSize

Start-Test "Bad user profile path"
Initialize-Table
Edit-Table "%HOME%\source\\repos\WindowsFirewallRuleset\" @RemoteParams
Get-Variable -Name InstallTable -ErrorAction Ignore |
Select-Object -ExpandProperty Value | Format-Table -AutoSize

Start-Test "Good user profile path"
Initialize-Table
$Result = Edit-Table "C:\\Users\$TestUser\\AppData\\Roaming\\" @RemoteParams
$Result
Get-Variable -Name InstallTable -ErrorAction Ignore |
Select-Object -ExpandProperty Value | Format-Table -AutoSize

Test-Output $Result -Command Edit-Table

Update-Log
Exit-Test #-Private
