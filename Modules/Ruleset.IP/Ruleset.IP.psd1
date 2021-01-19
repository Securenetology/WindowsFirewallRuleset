
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

#
# Module manifest for module "Ruleset.IP"
#
# Generated by: metablaster
#
# Generated on: 3.9.2020.
#

@{
	# Script module or binary module file associated with this manifest, (alias: ModuleToProcess)
	# Previous versions of PowerShell called this element the ModuleToProcess.
	# NOTE: To create a manifest module this must be empty,
	# the name of a script module (.psm1) creates a script module,
	# the name of a binary module (.exe or .dll) creates a binary module.
	RootModule = "Ruleset.IP.psm1"

	# Version number of this module.
	ModuleVersion = "0.10.1"

	# Supported PSEditions
	CompatiblePSEditions = @(
		"Core"
		"Desktop"
	)

	# ID used to uniquely identify this module
	GUID = "2f356d8c-aad0-462f-9cd7-fff31c7ab1d0"

	# Author of this module
	Author = "Chris Dent"

	# Company or vendor of this module
	# CompanyName = "Unknown"

	# Copyright statement for this module
	Copyright = "Copyright (C) 2016 Chris Dent"

	# Description of the functionality provided by this module
	Description = "Module to perform IPv4 subnet math"

	# Minimum version of the PowerShell engine required by this module
	# Valid values are: 1.0 / 2.0 / 3.0 / 4.0 / 5.0 / 5.1 / 6.0 / 6.1 / 6.2 / 7.0 / 7.1
	PowerShellVersion = "5.1"

	# Name of the Windows PowerShell host required by this module
	# PowerShellHostName = ""

	# Minimum version of the Windows PowerShell host required by this module
	# PowerShellHostVersion = ""

	# Minimum version of Microsoft .NET Framework required by this module
	# This prerequisite is valid for the PowerShell Desktop edition only.
	# Valid values are: 1.0 / 1.1 / 2.0 / 3.0 / 3.5 / 4.0 / 4.5
	DotNetFrameworkVersion = "4.5"

	# Minimum version of the common language runtime (CLR) required by this module.
	# This prerequisite is valid for the PowerShell Desktop edition only.
	# Valid values are: 1.0 / 1.1 / 2.0 / 4.0
	CLRVersion = "4.0"

	# Processor architecture (None, X86, Amd64) required by this module.
	# Valid values are: x86 / AMD64 / Arm / IA64 / MSIL / None (unknown or unspecified).
	ProcessorArchitecture = "None"

	# Modules that must be imported into the global environment prior to importing this module
	# RequiredModules = @()

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @()

	# Script files (.ps1) that are run in the caller's environment prior to importing this module.
	# ScriptsToProcess = @()

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @()

	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @("Ruleset.IP.Format.ps1xml")

	# Modules to import as nested modules of the module specified in RootModule.
	# Loading (.ps1) files here is equivalent to dot sourcing the script in your root module.
	# NestedModules = @()

	# Functions to export from this module
	FunctionsToExport = @(
		"ConvertFrom-HexIP"
		"ConvertTo-BinaryIP"
		"ConvertTo-DecimalIP"
		"ConvertTo-DottedDecimalIP"
		"ConvertTo-HexIP"
		"ConvertTo-Mask"
		"ConvertTo-MaskLength"
		"ConvertTo-Subnet"
		"Get-BroadcastAddress"
		"Get-NetworkAddress"
		"Get-NetworkRange"
		"Get-NetworkSummary"
		"Get-Subnet"
		"Resolve-IPAddress"
		"Test-SubnetMember"
	)

	# Cmdlets to export from this module, for best performance, do not use wildcards and do not
	# delete the entry, use an empty array if there are no cmdlets to export.
	CmdletsToExport = @()

	# Variables to export from this module.
	# Wildcard characters are permitted, by default, all variables ("*") are exported.
	VariablesToExport = @()

	# Aliases to export from this module, for best performance, do not use wildcards and do not
	# delete the entry, use an empty array if there are no aliases to export.
	AliasesToExport = @()

	# DSC resources to export from this module
	# DscResourcesToExport = @()

	# List of all modules packaged with this module.
	# These modules are not automatically processed.
	# ModuleList = @()

	# List of all files packaged with this module.
	# As with ModuleList, FileList is an inventory list.
	FileList = @(
		"en-US\about_Ruleset.IP.help.txt"
		"en-US\Ruleset.IP-help.xml"
		"Help\en-US\about_Ruleset.IP.md"
		"Help\en-US\ConvertFrom-HexIP.md"
		"Help\en-US\ConvertTo-BinaryIP.md"
		"Help\en-US\ConvertTo-DecimalIP.md"
		"Help\en-US\ConvertTo-DottedDecimalIP.md"
		"Help\en-US\ConvertTo-HexIP.md"
		"Help\en-US\ConvertTo-Mask.md"
		"Help\en-US\ConvertTo-MaskLength.md"
		"Help\en-US\ConvertTo-Subnet.md"
		"Help\en-US\Get-BroadcastAddress.md"
		"Help\en-US\Get-NetworkAddress.md"
		"Help\en-US\Get-NetworkRange.md"
		"Help\en-US\Get-NetworkSummary.md"
		"Help\en-US\Get-Subnet.md"
		"Help\en-US\Resolve-IPAddress.md"
		"Help\en-US\Ruleset.IP.md"
		"Help\en-US\Test-SubnetMember.md"
		"Help\README.md"
		"Private\ConvertTo-Network.ps1"
		"Private\Get-Permutation.ps1"
		"Private\README.md"
		"Public\ConvertFrom-HexIP.ps1"
		"Public\ConvertTo-BinaryIP.ps1"
		"Public\ConvertTo-DecimalIP.ps1"
		"Public\ConvertTo-DottedDecimalIP.ps1"
		"Public\ConvertTo-HexIP.ps1"
		"Public\ConvertTo-Mask.ps1"
		"Public\ConvertTo-MaskLength.ps1"
		"Public\ConvertTo-Subnet.ps1"
		"Public\Get-BroadcastAddress.ps1"
		"Public\Get-NetworkAddress.ps1"
		"Public\Get-NetworkRange.ps1"
		"Public\Get-NetworkSummary.ps1"
		"Public\Get-Subnet.ps1"
		"Public\README.md"
		"Public\Resolve-IPAddress.ps1"
		"Public\Test-SubnetMember.ps1"
		"Test\Private\ConvertTo-Network.test.ps1"
		"Test\Public\ConvertFrom-HexIP.test.ps1"
		"Test\Public\ConvertTo-BinaryIP.test.ps1"
		"Test\Public\ConvertTo-DecimalIP.test.ps1"
		"Test\Public\ConvertTo-DottedDecimalIP.test.ps1"
		"Test\Public\ConvertTo-HexIP.test.ps1"
		"Test\Public\ConvertTo-Mask.test.ps1"
		"Test\Public\ConvertTo-MaskLength.test.ps1"
		"Test\Public\ConvertTo-Subnet.test.ps1"
		"Test\Public\Get-BroadcastAddress.test.ps1"
		"Test\Public\Get-NetworkAddress.test.ps1"
		"Test\Public\Get-NetworkRange.test.ps1"
		"Test\Public\Get-NetworkSummary.test.ps1"
		"Test\Public\Get-Subnet.test.ps1"
		"Test\Public\Resolve-IPAddress.test.ps1"
		"Test\Public\Test-SubnetMember.test.ps1"
		"LICENSE"
		"README.md"
		"Ruleset.IP_2f356d8c-aad0-462f-9cd7-fff31c7ab1d0_HelpInfo.xml"
		"Ruleset.IP.Format.ps1xml"
		"Ruleset.IP.psd1"
		"Ruleset.IP.psm1"
	)

	# Specifies any private data that needs to be passed to the root module specified by the RootModule.
	# This contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		PSData = @{

			# Tags applied to this module.
			# These help with module discovery in online galleries.
			Tags = @(
				"IPMath"
				"IPCalculator"
				"SubnetMath"
			)

			# A URL to the license for this module.
			LicenseUri = "https://raw.githubusercontent.com/metablaster/WindowsFirewallRuleset/master/Modules/Ruleset.IP/LICENSE"

			# A URL to the main website for this project.
			ProjectUri = "https://github.com/metablaster/WindowsFirewallRuleset"

			# A URL to an icon representing this module.
			# IconUri = ""

			# ReleaseNotes of this module
			# ReleaseNotes = ""

			# A PreRelease string that identifies the module as a prerelease version in online galleries.
			Prerelease = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Readme/CHANGELOG.md"

			# Flag to indicate whether the module requires explicit user acceptance for
			# install, update, or save.
			RequireLicenseAcceptance = $true

			# A list of external modules that this module is dependent upon.
			# ExternalModuleDependencies = @()
		} # End of PSData hashtable
	} # End of PrivateData hashtable

	# HelpInfo URI of this module
	# HelpInfoURI = "https://raw.githubusercontent.com/metablaster/WindowsFirewallRuleset/master/Modules/Ruleset.IP/Ruleset.IP_2f356d8c-aad0-462f-9cd7-fff31c7ab1d0_HelpInfo.xml"

	# Default prefix for commands exported from this module.
	# Override the default prefix using Import-Module -Prefix.
	# DefaultCommandPrefix = ""
}
