
#
# Module manifest for module "PolicyFileEditor"
#
# Generated by: metablaster
#
# Generated on: 27.11.2022.
#

@{
	# Script module or binary module file associated with this manifest, (alias: ModuleToProcess)
	# Previous versions of PowerShell called this element the ModuleToProcess.
	# NOTE: To create a manifest module this must be empty,
	# the name of a script module (.psm1) creates a script module,
	# the name of a binary module (.exe or .dll) creates a binary module.
	RootModule = "PolicyFileEditor.psm1"

	# Version number of this module.
	# NOTE: Last checked out official version was 3.1.0
	ModuleVersion = "0.14.0"

	# Supported PSEditions
	CompatiblePSEditions = @(
		"Core"
		"Desktop"
	)

	# ID used to uniquely identify this module
	GUID = "110a2398-3053-4ffc-89d1-1b6a38a2dc86"

	# Author of this module
	Author = "Dave Wyatt"

	# Company or vendor of this module
	# CompanyName = "Unknown"

	# Copyright statement for this module
	Copyright = "Copyright (C) 2015 Dave Wyatt. All rights reserved."

	# Description of the functionality provided by this module
	Description = "Commands and DSC resource for modifying Administrative Templates settings in local GPO registry.pol files."

	# Minimum version of the PowerShell engine required by this module
	# Valid values are: 1.0 / 2.0 / 3.0 / 4.0 / 5.0 / 5.1 / 6.0 / 6.1 / 6.2 / 7.0 / 7.1
	PowerShellVersion = "2.0"

	# Name of the Windows PowerShell host required by this module
	# PowerShellHostName = ""

	# Minimum version of the Windows PowerShell host required by this module
	# PowerShellHostVersion = ""

	# Minimum version of Microsoft .NET Framework required by this module.
	# This prerequisite is valid for the PowerShell Desktop edition only.
	# Valid values are: 1.0 / 1.1 / 2.0 / 3.0 / 3.5 / 4.0 / 4.5
	DotNetFrameworkVersion = "2.0"

	# Minimum version of the common language runtime (CLR) required by this module.
	# This prerequisite is valid for the PowerShell Desktop edition only.
	# Valid values are: 1.0 / 1.1 / 2.0 / 4.0
	CLRVersion = "2.0"

	# Processor architecture (None, X86, Amd64) required by this module.
	# Valid values are: x86 / AMD64 / Arm / IA64 / MSIL / None (unknown or unspecified).
	ProcessorArchitecture = "None"

	# Modules that must be imported into the global environment prior to importing this module
	# RequiredModules = @()

	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @(
		"PolFileEditor.dll"
	)

	# TODO: Script files (.ps1) that are run in the caller's environment prior to importing this module.
	# ScriptsToProcess = @()

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @()

	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @()

	# Modules to import as nested modules of the module specified in RootModule.
	# Loading (.ps1) files here is equivalent to dot sourcing the script in your root module.
	# NestedModules = @()

	# Functions to export from this module, for best performance, do not use wildcards and do not
	# delete the entry, use an empty array if there are no functions to export.
	# NOTE: When the value of any *ToExport key is an empty array,
	# no objects of that type are exported, regardless of the value in the Export-ModuleMember
	FunctionsToExport = @(
		"Set-PolicyFileEntry"
		"Remove-PolicyFileEntry"
		"Get-PolicyFileEntry"
		"Update-GptIniVersion"
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
		"en-US\about_PolicyFileEditor.Help.txt"
		"en-US\PolicyFileEditor-help.xml"
		"Help\en-US\PolicyFileEditor.md"
		"Help\en-US\Get-PolicyFileEntry.md"
		"Help\en-US\Remove-PolicyFileEntry.md"
		"Help\en-US\Set-PolicyFileEntry.md"
		"Help\en-US\Update-GptIniVersion.md"
		"Help\en-US\PolicyFileEditor.md"
		"Help\README.md"
		"Private\Assert-ValidDataAndType.ps1"
		"Private\DataIsEqual.ps1"
		"Private\EnsureAdminTemplateCseGuidsArePresent.ps1"
		"Private\GetEntryData.ps1"
		"Private\GetNewVersionNumber.ps1"
		"Private\GetPolFilePath.ps1"
		"Private\GetSidForAccount.ps1"
		"Private\GetTargetResourceCommon.ps1"
		"Private\IncrementGptIniVersion.ps1"
		"Private\InvalidDataTypeCombinationErrorRecord.ps1"
		"Private\NewGptIni.ps1"
		"Private\OpenPolicyFile.ps1"
		"Private\ParseKeyValueName.ps1"
		"Private\PolEntryToPsObject.ps1"
		"Private\PolEntryTypeToRegistryValueKind.ps1"
		"Private\README.md"
		"Private\SavePolicyFile.ps1"
		"Private\SetTargetResourceCommon.ps1"
		"Private\TestTargetResourceCommon.ps1"
		"Private\UInt16PairToUInt32.ps1"
		"Private\UInt32ToUInt16Pair.ps1"
		"Public\Get-PolicyFileEntry.ps1"
		"Public\README.md"
		"Public\Remove-PolicyFileEntry.ps1"
		"Public\Set-PolicyFileEntry.ps1"
		"Public\Update-GptIniVersion.ps1"
		"Test\PolicyFileEditor.Tests.ps1"
		"LICENSE"
		"PolFileEditor.dll"
		"Ruleset.Initialize_41585bd3-3f4d-4669-9919-2d19c0451b73_HelpInfo.xml"
		"PolicyFileEditor.psd1"
		"PolicyFileEditor.psm1"
	)

	# Specifies any private data that needs to be passed to the root module specified by the RootModule.
	# This contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		PSData = @{

			# Tags applied to this module.
			# These help with module discovery in online galleries.
			Tags = @(
				"GPO"
			)

			# A URL to the license for this module.
			LicenseUri = "https://www.apache.org/licenses/LICENSE-2.0.html"

			# A URL to the main website for this project.
			ProjectUri = "https://github.com/metablaster/WindowsFirewallRuleset"

			# A URL to an icon representing this module.
			# The specified icon is displayed on the gallery webpage for the module
			IconUri = "https://raw.githubusercontent.com/metablaster/WindowsFirewallRuleset/master/Readme/Screenshots/bluewall.png"

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
	# HelpInfoURI = "https://raw.githubusercontent.com/metablaster/WindowsFirewallRuleset/master/Modules/PolicyFileEditor/PolicyFileEditor_110a2398-3053-4ffc-89d1-1b6a38a2dc86_HelpInfo.xml"

	# Default prefix for commands exported from this module.
	# Override the default prefix using Import-Module -Prefix.
	# DefaultCommandPrefix = ""
}
