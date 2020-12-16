
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
Generate or update help files for all project modules

.DESCRIPTION
UpdateHelp.ps1 Updates existing or generates new help files for all modules
that are part of "Windows Firewall Ruleset" repository
These Help files are used for online help (Get-Help -Online) and
updatable help for (Update-Help)

.PARAMETER Module
Specify module name for which to generate help files.
The default is all repository modules

.PARAMETER SupportedUICulture
Supported UI cultures for which to generate help files, the default is en-US

.PARAMETER Encoding
Specify encoding for help files.
The default is set by global variable, UTF8 no BOM for Core or UTF8 with BOM for Desktop edition

.EXAMPLE
PS> .\UpdateHelp.ps1

.EXAMPLE
PS> .\UpdateHelp.ps1 -IncrementVersion

.EXAMPLE
PS> .\UpdateHelp.ps1 SupportedUICulture @(en-US, fr-FR, jp-JP) -Encoding utf8

.INPUTS
None. You cannot pipe objects to UpdateHelp.ps1

.OUTPUTS
None. UpdateHelp.ps1 does not generate any output

.NOTES
See CONTRIBUTING.md in "documentation" section for examples of comment based help that will
produce errors while generating online help and how to avoid them.
Help version is automatically updated according to $ProjectVersion variable
TODO: some markdown files will end up with additional blank line at the end of document for each
update of help files.
TODO: Online hosting of help content is needed, for now the only purpose is to generate markdown
help files
TODO: Module page and about_ topic needs to be manually edited, currently we get template only
To document private functions they must be exported first
TODO: the "Module Name:" entry in help files (any maybe even "external help file:" entry),
if not set to correct module name the command will fail
#>

[CmdletBinding()]
param (
	[Parameter()]
	[string[]] $ModuleName,

	[Parameter()]
	[string[]] $SupportedUICulture = @(
		"en-US"
	),

	[Parameter()]
	$Encoding = $null
)

#region Initialization
#Requires -Version 5.1
. $PSScriptRoot\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value ((Get-Item $PSCommandPath).Basename)

if ($null -eq $Encoding)
{
	$Encoding = $DefaultEncoding
}

# TODO: Logging solution needed for cases before project initialization
if (!$Develop)
{
	# Run this script only to generate new or update existing online help before release
	Write-Error -Category NotEnabled -TargetObject $Develop `
		-Message "This script is enabled only in development mode"
	return
}

[PSModuleInfo[]] $PlatyModule = Get-Module -Name platyPS -ListAvailable
if ($null -eq $PlatyModule)
{
	Write-Error -Category ObjectNotFound -TargetObject $PlatyModule `
		-Message "Module platyPS needs to be installed to run this script"
	return
}

# Check requirements
Initialize-Project -Abort
Write-Debug -Message "[$ThisScript] params($($PSBoundParameters.Values))"

# Imports
. $PSScriptRoot\ContextSetup.ps1

<#
.SYNOPSIS
Formatting according to recommended markdown style

.PARAMETER FileName
Markdown file
#>
function Format-Document
{
	[CmdletBinding()]
	param (
		[Parameter()]
		[string] $FileName
	)

	$MarkdownFile = Split-Path -Path $FileName -Leaf
	Write-Information -Tags "Project" -MessageData "INFO: Formatting document $MarkdownFile"
	$FileData = Get-Content -Path $FileName -Encoding $Encoding -Raw

	# Blank line after heading
	Write-Verbose -Message "[$ThisScript] Setting blank lines around headings in $MarkdownFile"
	$FileData = $FileData -replace '(?m)(?<heading>^#+\s.+$\n)(?=\S)', "`${heading}`r`n"

	# Empty code fences
	# NOTE: module page has no code fences
	Write-Verbose -Message "[$ThisScript] Setting explicit code fences in $MarkdownFile"
	$FileData = $FileData -replace '(?m)(?<fence>^```)(?=\r\n\w+)', "`${fence}none"

	# TODO: new line is inserted in module page, NoNewline ignored
	Set-Content -NoNewline -Path $FileName -Value $FileData -Encoding $Encoding
}

# User prompt
$Accept = "Generate new or update existing help files for all project modules"
$Deny = "Abort operation, no change to help files is made"
if ($ModuleName)
{
	$Accept = "Generate new or update existing help files for requested modules"
}

Update-Context $ScriptContext $ThisScript
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Unsafe)) { exit }
#endregion

Write-Debug -Message "[$ThisScript] params($($PSBoundParameters.Values))"

# Setup local variables
# Root directory of help content for current module and culture
[string] $HelpContent = "$ProjectRoot\Config\HelpContent\$ProjectVersion"

if (!$ModuleName)
{
	# Generate new or update existing help files for all modules that are part of repository
	$ModuleName = Get-ChildItem -Path $ProjectRoot\Modules\ -Directory -Filter "Ruleset.*" |
	Select-Object -ExpandProperty Name
}

# Counters for progress
[int32] $ProgressCount = 0
[string] $UpgradeLogsDir = "$ProjectRoot\Logs\UpdateHelp"

# NOTE: separate folder for upgrade logs
if (!(Test-Path -PathType Container -Path $UpgradeLogsDir))
{
	New-Item -ItemType Container -Path $UpgradeLogsDir | Out-Null
}

foreach ($Module in $ModuleName)
{
	Write-Debug -Message "[$ThisScript] Processing module: $Module"

	# NOTE: Module must be imported to avoid warnings from platyPS
	Import-Module -Name $Module
	[PSModuleInfo] $ModuleInfo = Get-Module -Name $Module

	# Root directory of current module
	[string] $ModuleRoot = $ModuleInfo.ModuleBase

	# Populate help directory and readme if not present
	if (!(Test-Path -Path $ModuleRoot\Help))
	{
		New-Item -Path $ModuleRoot\Help -ItemType Container | Out-Null
	}

	$Readme = "$ModuleRoot\Help\README.md"
	if (!(Test-Path -Path $Readme))
	{
		New-Item -Path $Readme -ItemType File | Out-Null
		Set-Content -Path $Readme -Encoding $Encoding -Value @"

# Help directory

Contains online help files in markdown format.\
These files are used for online reading ex. with `Get-Help -Online`

**NOTE:** The procedure to generate help files will create local only temporary folders in language
specific subfolders
"@
	}

	foreach ($UICulture in $SupportedUICulture)
	{
		Write-Progress -Activity "Creating help files" -CurrentOperation $Module -Status $UICulture `
			-PercentComplete (++$ProgressCount / $ModuleName.Length * $SupportedUICulture.Length * 100)

		Write-Debug -Message "[$ThisScript] Processing culture: $UICulture"

		# Root directory of external help files for current module and culture
		[string] $ExternalHelp = "$ModuleRoot\$UICulture"

		# Root directory of online help files for current module and culture
		[string] $OnlineHelp = "$ModuleRoot\Help\$UICulture"

		# Help content download link for Update-Help commandlet
		# This value is required for .cab file creation.
		# This value is used as markdown header metadata in the module page
		[string] $DownloadLink = "https://github.com/metablaster/WindowsFirewallRuleset/tree/master/Config/HelpContent/$ProjectVersion"

		# Module page file
		[string] $ModulePage = "$OnlineHelp\$Module.md"

		# Both the help root folder and module page must exist to update
		if (Test-Path -Path $ModulePage -PathType Leaf)
		{
			Write-Verbose -Message "[$ThisScript] Updating help: $Module - $UICulture"

			# If download link is out of date replace it
			$FileData = Get-Content -Path $ModulePage -Encoding $Encoding

			if ([string]::IsNullOrEmpty($FileData -match "^Download Help Link: $DownloadLink$"))
			{
				Write-Information -Tags "Project" -MessageData "INFO: Updating download link in $Module.md"
				$FileData -replace "(?<=Download Help Link:).*", " $DownloadLink" |
				Set-Content -Path $ModulePage -Encoding $Encoding
			}

			# Updates existing help markdown files and creates markdown files for new cmdlets in a module
			# NOTE: updates module page but not about_ topics
			# NOTE: Generates blank module page if missing
			# -Path string[] The folder must contain a module page from which this cmdlet can get the module name
			Update-MarkdownHelpModule -Encoding $Encoding -Path $OnlineHelp -UpdateInputOutput `
				-LogPath $UpgradeLogsDir\$Module-UpdateHelp.log -UseFullTypeName `
				-RefreshModulePage -Force -ModulePagePath $ModulePage |
			Select-Object -ExpandProperty Name

			# If help version is out of date or missing set it
			$FileData = Get-Content -Path $ModulePage -Encoding $Encoding

			if ([string]::IsNullOrEmpty($FileData -match "Help Version:\s$ProjectVersion"))
			{
				Write-Information -Tags "Project" -MessageData "INFO: Updating module page version"
				$FileData = $FileData -replace "(?<=Help Version:).*", " $ProjectVersion"
				Set-Content -Path $ModulePage -Value $FileData -Encoding $Encoding
			}
		}
		else # Generate new help files
		{
			Write-Verbose -Message "[$ThisScript] Generating new help: $Module - $UICulture"

			# NOTE: Need to run to generate module page
			# Regenerates all help files, new ones will be later updated to include "online version" metadata
			# Create new markdown help files (module page included, about module not included)
			New-MarkdownHelp -Module $Module -Encoding $Encoding -OutputFolder $OnlineHelp `
				-UseFullTypeName -WithModulePage -HelpVersion $ProjectVersion -Locale $UICulture `
				-FwLink $DownloadLink -ModulePagePath $ModulePage -Force |
			Select-Object -ExpandProperty Name
			# -Metadata $HelpMetadata
		}

		# NOTE: Need to run to add "online version" metadata to newly generated files which are missing the link
		# Also to perform formatting according to recommended markdown style
		$ModuleFunctions = ($ModuleInfo | Select-Object -ExpandProperty ExportedFunctions).GetEnumerator() |
		Select-Object -ExpandProperty Key

		foreach ($Command in $ModuleFunctions)
		{
			Write-Information -Tags "Project" -MessageData "INFO: Formatting document $Command.md"

			# Read file and single line string preserving line break characters
			$FileData = Get-Content -Path $OnlineHelp\$Command.md -Encoding $Encoding -Raw
			$OnlineVersion = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/$Module/Help/$UICulture/$Command.md"

			# If online help link is out of date or missing set it
			if (!($FileData -match "online version:\s$OnlineVersion"))
			{
				Write-Verbose -Message "[$ThisScript] Updating online help link in $Command.md"
				$FileData = $FileData -replace "(?<=online version:).*", " $OnlineVersion"
			}

			# NOTE: NoNewline needed, otherwise each file ends up with 2 final new lines
			Set-Content -NoNewline -Path $OnlineHelp\$Command.md -Value $FileData -Encoding $Encoding

			Format-Document $OnlineHelp\$Command.md
		}

		# Format module page
		Format-Document $ModulePage

		# NOTE: Creating about_ topics is independent of both the Update and New-MarkdownHelp
		if (Test-Path -Path $OnlineHelp\about_$Module.md -PathType Leaf)
		{
			Write-Verbose -Message "[$ThisScript] about_$Module.md is present, no change to file"
		}
		else
		{
			Write-Verbose -Message "[$ThisScript] Generating new about_$Module.md"

			# New about_ModuleName help topic
			New-MarkdownAboutHelp -OutputFolder $OnlineHelp -AboutName $Module
		}

		# Format about topic
		Format-Document $OnlineHelp\about_$Module.md

		Write-Verbose -Message "[$ThisScript] Generating external help"

		# Create new XML help file and *.txt about file or override existing ones
		# TODO: maybe global variable for line width, MaxAboutWidth affects only about_ files
		# NOTE: Creates external help based on files or folders specified in -Path string[]
		New-ExternalHelp -Path $OnlineHelp -Encoding $Encoding -OutputPath $OnlineHelp\External `
			-MaxAboutWidth 120 -ErrorLogFile $UpgradeLogsDir\$Module-ExternalHelp.log -Force |
		Select-Object -ExpandProperty Name
		# -ShowProgress

		Write-Verbose -Message "[$ThisScript] Generating help content"

		# Generate updatable help content
		# NOTE: Requires the path to module page which contains required metadata to name cab file
		# NOTE: Recommend to provide as content only about_ topics and the output from the New-ExternalHelp
		# TODO: resulting helpinfo xml is UTF8 with BOM
		New-ExternalHelpCab -CabFilesFolder $OnlineHelp\External -OutputFolder $OnlineHelp\Content `
			-LandingPagePath $ModulePage | Out-Null
		# -IncrementHelpVersion

		# TODO: maybe moving files instead of copying
		Write-Information -Tags "Project" -MessageData "INFO: Copying generated help files to default location"

		# Copy HelpInfo file to default destination
		Copy-Item -Path $OnlineHelp\Content\* -Filter *.xml -Destination $ModuleRoot

		# Copy required help content to default destination
		if (!(Test-Path -Path $HelpContent -PathType Container))
		{
			New-Item -Path $HelpContent -ItemType Container | Out-Null
		}

		Copy-Item -Path $OnlineHelp\Content\* -Filter *.cab -Destination $HelpContent

		# Copy required external help to default destination
		if (!(Test-Path -Path $ExternalHelp -PathType Container))
		{
			New-Item -Path $ExternalHelp -ItemType Container | Out-Null
		}

		# TODO: We're skipping copying about_ topic file to prevent overwriting original with template
		Copy-Item -Path $OnlineHelp\External\* -Filter *.xml -Destination $ExternalHelp

		Update-Log
	} # foreach culture

	Update-Log
} # foreach module

Update-Log
