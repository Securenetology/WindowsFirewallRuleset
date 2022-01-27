
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020 Markus Scholtes
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
Imports firewall rules from a CSV or JSON file

.DESCRIPTION
Imports firewall rules generated with Export-FirewallRule, CSV or JSON file.
CSV files have to be separated with semicolons.
Existing rules with same name will be overwritten.

.PARAMETER Domain
Policy store into which to import rules, default is local GPO.

.PARAMETER Path
Path to directory where exported rules file is located

.PARAMETER FileName
Input file

.PARAMETER JSON
Input from JSON instead of CSV format

.EXAMPLE
PS> Import-FirewallRule

Imports all firewall rules in the CSV file FirewallRules.csv
If no file is specified, FirewallRules .csv or .json in the current directory is searched.

.EXAMPLE
PS> Import-FirewallRule -FileName WmiRules -JSON

Imports all firewall rules from the JSON file WmiRules

.INPUTS
None. You cannot pipe objects to Import-FirewallRule

.OUTPUTS
None. Import-FirewallRule does not generate any output

.NOTES
Author: Markus Scholtes
Version: 1.02
Build date: 2020/02/15

Following modifications by metablaster August 2020:
1. Applied formatting and code style according to project rules
2. Added parameter to target specific policy store
3. Separated functions into their own scope
4. Added function to decode string into multi line
5. Added parameter to let specify directory
6. Added more output streams for debug, verbose and info
7. Changed minor flow and logic of execution
8. Make output formatted and colored
9. Added progress bar
December 2020:
1. Rename parameters according to standard name convention
2. Support resolving path wildcard pattern

.LINK
https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Firewall/Help/en-US/Import-FirewallRule.md

.LINK
https://github.com/MScholtes/Firewall-Manager
#>
function Import-FirewallRule
{
	[CmdletBinding(PositionalBinding = $false,
		HelpURI = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Firewall/Help/en-US/Import-FirewallRule.md")]
	[OutputType([void])]
	param (
		[Parameter()]
		[Alias("ComputerName", "CN")]
		[string] $Domain = [System.Environment]::MachineName,

		[Parameter(Mandatory = $true)]
		[SupportsWildcards()]
		[System.IO.DirectoryInfo] $Path,

		[Parameter()]
		[string] $FileName = "FirewallRules",

		[Parameter()]
		[switch] $JSON
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] ParameterSet = $($PSCmdlet.ParameterSetName):$($PSBoundParameters | Out-String)"

	$Path = [System.IO.DirectoryInfo] (Resolve-Path $Path.FullName).Path
	if (!$Path -or !$Path.Exists)
	{
		Write-Error -Category ResourceUnavailable -Message "The path was not found: $Path"
		return
	}

	# NOTE: Split-Path -Extension is not available in Windows PowerShell
	$FileExtension = [System.IO.Path]::GetExtension($FileName)

	if ($JSON)
	{
		# read JSON file
		if (!$FileExtension)
		{
			Write-Debug -Message "[$($MyInvocation.InvocationName)] Adding extension to input file"
			$FileName += ".json"
		}
		elseif ($FileExtension -ne ".json")
		{
			Write-Warning -Message "Unexpected file extension '$FileExtension'"
		}

		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Reading JSON file"
		Confirm-FileEncoding "$Path\$FileName"
		$FirewallRules = Get-Content "$Path\$FileName" -Encoding $DefaultEncoding | ConvertFrom-Json
	}
	else
	{
		# read CSV file
		if (!$FileExtension)
		{
			Write-Debug -Message "[$($MyInvocation.InvocationName)] Adding extension to input file"
			$FileName += ".csv"
		}
		elseif ($FileExtension -ne ".csv")
		{
			Write-Warning -Message "Unexpected file extension '$FileExtension'"
		}

		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Reading CSV file"
		Confirm-FileEncoding "$Path\$FileName"
		$FirewallRules = Get-Content "$Path\$FileName" -Encoding $DefaultEncoding | ConvertFrom-Csv -Delimiter ";"
	}

	Write-Debug -Message "[$($MyInvocation.InvocationName)] Iterating rules"

	# Counter for progress
	[int32] $RuleCount = 0

	# iterate rules
	foreach ($Rule In $FirewallRules)
	{
		# TODO: -SecondsRemaining needs to be updated after precise speed test
		Write-Progress -Activity "Importing firewall rules" -PercentComplete (++$RuleCount / $FirewallRules.Length * 100) `
			-CurrentOperation $Rule.DisplayName -Status $Rule.Group `
			-SecondsRemaining (($FirewallRules.Length - $RuleCount + 1) / 26 * 60)

		# Create Hashtable for New-NetFirewallRule parameters
		$RuleSplatHash = @{
			Name = $Rule.Name
			Displayname = $Rule.Displayname
			Group = $Rule.Group
			Profile = $Rule.Profile
			Enabled = $Rule.Enabled
			Action = $Rule.Action
			Service = $Rule.Service
			Program = $Rule.Program
			LocalAddress = Convert-ListToArray $Rule.LocalAddress
			RemoteAddress = Convert-ListToArray $Rule.RemoteAddress
			Protocol = $Rule.Protocol
			IcmpType = Convert-ListToArray $Rule.IcmpType
			LocalPort = Convert-ListToArray $Rule.LocalPort
			RemotePort = Convert-ListToArray $Rule.RemotePort
			LocalUser = $Rule.LocalUser
			RemoteUser = $Rule.RemoteUser
			InterfaceType = $Rule.InterfaceType
			InterfaceAlias = Convert-ListToArray $Rule.InterfaceAlias
			EdgeTraversalPolicy = $Rule.EdgeTraversalPolicy
			Direction = $Rule.Direction
			Platform = Convert-ListToArray $Rule.Platform @()
			LooseSourceMapping = Convert-ValueToBoolean $Rule.LooseSourceMapping
			LocalOnlyMapping = Convert-ValueToBoolean $Rule.LocalOnlyMapping
			DynamicTarget = if ([string]::IsNullOrEmpty($Rule.DynamicTarget)) { "Any" } else { $Rule.DynamicTarget }
			RemoteMachine = $Rule.RemoteMachine
			Authentication = $Rule.Authentication
			Encryption = $Rule.Encryption
			OverrideBlockRules = Convert-ValueToBoolean $Rule.OverrideBlockRules
			Description = Convert-ListToMultiLine $Rule.Description -JSON:$JSON
		}

		# For SID types no empty value is defined, therefore omit if not present
		if (![string]::IsNullOrEmpty($Rule.Owner))
		{
			# TODO: For rule owner, "Any" refers to any owner? for store apps owner must be explicit?
			if ($Rule.Owner -eq "Any")
			{
				$LoginName = ""
			}
			else
			{
				$LoginName = (ConvertFrom-SID $Rule.Owner).Name
			}

			# NOTE: We're assuming "Any" is not valid for store app rule
			if ([string]::IsNullOrEmpty($LoginName))
			{
				Write-Warning -Message "Importing rule '$($Rule.Displayname)' skipped, store app owner is missing or does not exist"
				continue
			}
			elseif (![string]::IsNullOrEmpty($Rule.Package))
			{
				# For rule package, "*" refers to store apps only, and "Any" refers to all programs and application packages
				if ($Rule.Package -eq "Any")
				{
					$PackageName = ""
				}
				elseif ($Rule.Package -eq "*")
				{
					$PackageName = "*"
				}
				else
				{
					$PackageName = (ConvertFrom-SID $Rule.Package).Name
				}

				# NOTE: We're assuming "Any" is not valid for store app rule
				if ([string]::IsNullOrEmpty($PackageName))
				{
					Write-Warning -Message "Importing rule '$($Rule.Displayname)' skipped, store app package is missing or does not exist"
					continue
				}
				else
				{
					$RuleSplatHash.Owner = $Rule.Owner
					$RuleSplatHash.Package = $Rule.Package
				}
			}
			else
			{
				Write-Warning -Message "Importing rule '$($Rule.Displayname)' skipped, store app package is missing"
				continue
			}
		}

		# Remove rule if present
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Checking if rule exists"

		$IsRemoved = @()
		Remove-NetFirewallRule -Name $Rule.Name -PolicyStore $Domain -ErrorAction SilentlyContinue -ErrorVariable IsRemoved

		if ($IsRemoved.Count -gt 0)
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Not replacing rule"
		}
		else
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Replacing existing rule"
		}

		# Create new firewall rule, parameters are assigned with splatting
		# NOTE: If the script is not run as Administrator, the error says "Cannot create a file when that file already exists"
		New-NetFirewallRule -PolicyStore $Domain @RuleSplatHash | Format-RuleOutput -Import
	}

	Write-Information -Tags $MyInvocation.InvocationName -MessageData "INFO: Importing firewall rules from '$FileName' done"
}
