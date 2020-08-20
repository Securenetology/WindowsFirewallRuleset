
<#
MIT License

Project: "Windows Firewall Ruleset" serves to manage firewall on Windows systems
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

Set-StrictMode -Version Latest
Set-Variable -Name ThisModule -Scope Script -Option ReadOnly -Force -Value ($MyInvocation.MyCommand.Name -replace ".{5}$")

# Imports
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 -InsideModule $true

# TODO: repository paths whitelist check
# TODO: should process must be implemented for system changes
# if (!$PSCmdlet.ShouldProcess("ModuleName", "Update or install module if needed"))
# SupportsShouldProcess = $true, ConfirmImpact = 'High'

#
# Module preferences
#

if ($Develop)
{
	$ErrorActionPreference = $ModuleErrorPreference
	$WarningPreference = $ModuleWarningPreference
	$DebugPreference = $ModuleDebugPreference
	$VerbosePreference = $ModuleVerbosePreference
	$InformationPreference = $ModuleInformationPreference

	Write-Debug -Message "[$ThisModule] ErrorActionPreference is $ErrorActionPreference"
	Write-Debug -Message "[$ThisModule] WarningPreference is $WarningPreference"
	Write-Debug -Message "[$ThisModule] DebugPreference is $DebugPreference"
	Write-Debug -Message "[$ThisModule] VerbosePreference is $VerbosePreference"
	Write-Debug -Message "[$ThisModule] InformationPreference is $InformationPreference"
}
else
{
	# Everything is default except InformationPreference should be enabled
	$InformationPreference = "Continue"
}

<#
.SYNOPSIS
Test if required system services are started
.DESCRIPTION
Test if required system services are started, some services are essential for
correct firewall and network functioning, without essential services project code
may result in errors hard to debug
.PARAMETER Services
An array of services to start
.EXAMPLE
A sample command that uses the function or script,
optionally followed by sample output and a description. Repeat this keyword for each example.
.INPUTS
[string[]] One or more service short names to check
.OUTPUTS
None.
.NOTES
[System.ServiceProcess.ServiceController[]]
#>
function Initialize-Service
{
	[OutputType([bool])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string[]] $Services
	)

	begin
	{
		# User prompt default values
		[int32] $Default = 0
		[System.Management.Automation.Host.ChoiceDescription[]] $Choices = @()
		$Accept = [System.Management.Automation.Host.ChoiceDescription]::new("&Yes")
		$Deny = [System.Management.Automation.Host.ChoiceDescription]::new("&No")
		$Deny.HelpMessage = "Skip operation"
		[string] $Title = "Required service not running"
		[bool] $StatusGood = $true
	}
	process
	{
		Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

		foreach ($InputService in $Services)
		{
			$StatusGood = $true
			$Service = Get-Service -Name $InputService

			if ($Service.Status -ne "Running")
			{
				[string] $Question = "Do you want to start $($Service.DisplayName) service now?"
				$Accept.HelpMessage = switch ($Service.Name)
				{
					"lmhosts"
					{
						"Required to manage GPO and contact computers on network using NETBIOS name resolution"
					}
					"LanmanWorkstation"
					{
						"Required to manage GPO and contact computers on network using SMB protocol"
					}
					"LanmanServer"
					{
						"Required to manage GPO firewall"
					}
					"WinRM"
					{
						"Required for remote firewall administration"
					}
					default
					{
						"Start service and set to automatic start"
					}
				}

				$Choices.Clear()
				$Choices += $Accept
				$Choices += $Deny

				$Decision = $Host.UI.PromptForChoice($Title, $Question, $Choices, $Default)

				if ($Decision -eq $Default)
				{
					$RequiredServices = Get-Service -Name $Service.Name -RequiredServices

					foreach ($Required in $RequiredServices)
					{
						# For dependent services print only failures
						if ($Required.StartType -ne "Automatic")
						{
							Set-Service -Name $Required.Name -StartupType Automatic
							$Startup = Get-Service -Name $Required.Name | Select-Object -ExpandProperty StartupType

							if ($Startup -ne "Automatic")
							{
								Write-Warning -Message "Dependent service $($Required.DisplayName) set to automatic failed"
							}
							else
							{
								Write-Verbose -Message "Setting dependent $($Required.DisplayName) service to autostart succeeded"
							}
						}

						if ($Required.Status -ne "Running")
						{
							Start-Service -Name $Required.Name
							$Status = Get-Service -Name $Required.Name | Select-Object -ExpandProperty Status

							if ($Status -ne "Running")
							{
								Write-Error -Category OperationStopped -TargetObject $Required `
									-Message "Unable to proceed, Dependent services can't be started"
								Write-Information -Tags "User" -MessageData "INFO: Starting dependent service '$($Required.DisplayName)' failed, please start manually and try again"
								return $false
							}
							else
							{
								Write-Verbose -Message "Starting dependent $($Required.DisplayName) service succeeded"
							}
						}
					} # Required Services

					# If decision is no, or if service is running there is no need to modify startup type
					# Otherwise set startup type after requirements are met
					if ($Service.StartType -ne "Automatic")
					{
						Set-Service -Name $Service.Name -StartupType Automatic
						$Startup = Get-Service -Name $Service.Name | Select-Object -ExpandProperty StartupType

						if ($Startup -ne "Automatic")
						{
							Write-Warning -Message "Set service $($Service.DisplayName) to automatic failed"
						}
						else
						{
							Write-Verbose -Message "Setting $($Service.DisplayName) service to autostart succeeded"
						}
					}

					# Required services and startup is checked, start input service
					# Status was already checked
					Start-Service -Name $Service.Name
					$Status = Get-Service -Name $Service.Name | Select-Object -ExpandProperty Status

					if ($Status -eq "Running")
					{
						Write-Information -Tags "User" -MessageData "INFO: Starting $($Service.DisplayName) service succeeded"
					}
					else
					{
						$StatusGood = $false
						Write-Information -Tags "User" -MessageData "INFO: Starting $($Service.DisplayName) service failed, please start manually and try again"
					}
				}
				else
				{
					# User refused default action
					$StatusGood = $false
				}

				if (!$StatusGood)
				{
					Write-Error -Category OperationStopped -TargetObject $Service `
						-Message "Unable to proceed, required services are not started"
					return $false
				}
			} # if service not running
		} # foreach InputService

		return $true
	}
}

<#
.SYNOPSIS
Check if recommended modules are installed
.DESCRIPTION
Test if recommended and up to date modules are installed, if not user is
prompted to install or update them.
Outdated or missing modules can cause strange issues, this function ensures latest modules are
installed and in correct order, taking into account failures that can happen while
installing or updating modules
.PARAMETER ModuleFullName
Hash table with a minimum ModuleName and ModuleVersion keys, in the form of ModuleSpecification
.PARAMETER Repository
Repository name from which to download module such as PSGallery,
if repository is not registered user is prompted to register it
.PARAMETER RepositoryLocation
Repository location associated with repository name,
this parameter is used only if repository is not registered
.PARAMETER InstallationPolicy
If the supplied repository needs to be registered InstallationPolicy specifies
whether repository is trusted or not.
this parameter is used only if repository is not registered
.PARAMETER InfoMessage
Help message used for default choice in host prompt
.PARAMETER AllowPrerelease
whether to allow installing beta modules
.EXAMPLE
Initialize-ModulesRequirement @{ ModuleName = "PackageManagement"; ModuleVersion = "1.4.7" } -Repository "PSGallery"
.INPUTS
None. You cannot pipe objects to Initialize-Module
.OUTPUTS
None.
.NOTES
Before updating PowerShellGet or PackageManagement, you should always install the latest Nuget provider
Updating PackageManagement and PowerShellGet requires restarting PowerShell to switch to the latest version
#>
function Initialize-Module
{
	[OutputType([bool])]
	[CmdletBinding(PositionalBinding = $false)]
	param (
		[Parameter(Mandatory = $true, Position = 0,
			HelpMessage = "Specify module to check in the form of ModuleSpecification object")]
		[ValidateNotNullOrEmpty()]
		[hashtable] $ModuleFullName,

		[Parameter()]
		[ValidatePattern("^[a-zA-Z]+$")]
		[string] $Repository = "PSGallery",

		[Parameter()]
		[ValidatePattern("[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)")]
		[uri] $RepositoryLocation = "https://www.powershellgallery.com/api/v2",

		[Parameter()]
		[ValidateSet("Trusted", "UnTrusted")]
		[string] $InstallationPolicy = "UnTrusted",

		[Parameter()]
		[string] $InfoMessage = "Accept operation",

		[Parameter()]
		[switch] $AllowPrerelease
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

	# Validate module specification
	if (!($ModuleFullName.Count -ge 2 -and
			($ModuleFullName.ContainsKey("ModuleName") -and $ModuleFullName.ContainsKey("ModuleVersion"))))
	{
		Write-Error -Category InvalidArgument -TargetObject $ModuleFullName `
			-Message "ModuleSpecification parameter for: $($ModuleFullName.ModuleName) is not valid"
		return $false
	}

	# Get required module from input
	[string] $ModuleName = $ModuleFullName.ModuleName
	[version] $RequiredVersion = $ModuleFullName.ModuleVersion

	Write-Debug -Message "[$($MyInvocation.InvocationName)] Checking if module $ModuleName is installed and what version"

	# Highest version present on system if any
	[version] $TargetVersion = Get-Module -Name $ModuleName -ListAvailable |
	Sort-Object -Property Version | Select-Object -Last 1 -ExpandProperty Version

	if ($TargetVersion)
	{
		if ($TargetVersion -ge $RequiredVersion)
		{
			# Up to date
			Write-Information -Tags "User" -MessageData "INFO: Installed module $ModuleName v$TargetVersion meets >= v$RequiredVersion"
			return $true
		}

		Write-Debug -Message "[$($MyInvocation.InvocationName)] Module $ModuleName v$TargetVersion found"
	}

	if (($ModuleName -eq "posh-git") -and !$script:GitInstance)
	{
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Checking if git.exe is in PATH required by module $ModuleName"

		if ($TargetVersion)
		{
			Write-Warning -Message "$ModuleName requires git in PATH but git.exe is not present"
		}
		else
		{
			Write-Error -Category NotInstalled -TargetObject $script:GitInstance `
				-Message "$ModuleName requires git.exe in PATH"
			return $false
		}
	}

	# User prompt default values
	[int32] $Default = 0
	[System.Management.Automation.Host.ChoiceDescription[]] $Choices = @()
	$Accept = [System.Management.Automation.Host.ChoiceDescription]::new("&Yes")
	$Deny = [System.Management.Automation.Host.ChoiceDescription]::new("&No")
	$Deny.HelpMessage = "Skip operation"

	# TODO: check for NuGet
	# Check for PowerShellGet only if not processing PowerShellGet
	if ($ModuleName -ne "PowerShellGet")
	{
		[version] $RequiredPowerShellGet = "2.2.4"
		Write-Debug -Message "[$($MyInvocation.InvocationName)] Checking if module PowerShellGet v$RequiredPowerShellGet is installed"

		# NOTE: Importing module to learn version could result in error
		[version] $TargetPowerShellGet = Get-Module -Name PowerShellGet -ListAvailable |
		Sort-Object -Property Version | Select-Object -Last 1 -ExpandProperty Version

		if (!$TargetPowerShellGet -or ($TargetPowerShellGet -lt $RequiredPowerShellGet))
		{
			Write-Error -Category NotInstalled -TargetObject $TargetPowerShellGet `
				-Message "Module PowerShellGet v$RequiredPowerShellGet must be installed before other modules, v$TargetPowerShellGet is installed"
			return $false
		}

		Write-Debug -Message "[$($MyInvocation.InvocationName)] Module PowerShellGet v$TargetPowerShellGet found"
	}

	# Check requested repository is registered
	Write-Debug -Message "[$($MyInvocation.InvocationName)] Checking if repository $Repository is registered"

	# Repository name only list
	[string] $RepositoryList = ""

	# Available repositories
	[PSCustomObject[]] $Repositories = Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue

	if ($Repositories)
	{
		$RepositoryList = $Repository
	}
	else
	{
		# Setup choices
		$Accept.HelpMessage = "Registered repositories are user-specific, they are not registered in a system-wide context"
		$Choices += $Accept
		$Choices += $Deny

		$Title = "Repository $Repository not registered"
		$Question = "Register $Repository repository now?"
		$Decision = $Host.UI.PromptForChoice($Title, $Question, $Choices, $Default)

		if ($Decision -eq $Default)
		{
			Write-Information -Tags "User" -MessageData "INFO: Registering repository $Repository"
			# Register repository to be able to use it
			Register-PSRepository -Name $Repository -SourceLocation $RepositoryLocation -InstallationPolicy $InstallationPolicy

			$RepositoryObject = Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue

			if ($RepositoryObject)
			{
				$Repositories += $RepositoryObject
				Write-Verbose -Message "[$($MyInvocation.InvocationName)] Repository $Repository is registered and $($Repositories[0].InstallationPolicy)"
			}
			# else error should be displayed
		}
		else
		{
			# Use default repositories registered by user
			$Repositories = Get-PSRepository
		}

		if (!$Repositories)
		{
			# Registering repository failed or no valid repository exists
			Write-Error -Category ObjectNotFound -TargetObject $Repositories `
				-Message "No registered repositories exist"
			return $false
		}
		else
		{
			Write-Debug -Message "[$($MyInvocation.InvocationName)] Constructing list of repositories for display"

			# Construct list for display on single line
			foreach ($RepositoryItem in $Repositories)
			{
				$RepositoryList += $RepositoryItem.Name
				$RepositoryList += ", "
			}

			$RepositoryList.TrimEnd(", ")
		}
	}

	# No need to specify type of repository, it's explained by user action
	Write-Information -Tags "User" -MessageData "INFO: Using following repositories: $RepositoryList"

	# Check if module could be downloaded
	[PSCustomObject] $FoundModule = $null
	Write-Debug -Message "[$($MyInvocation.InvocationName)] Checking if module $ModuleName version >= v$RequiredVersion could be downloaded"

	foreach ($RepositoryItem in $Repositories)
	{
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Checking repository $RepositoryItem for updates"

		[uri] $RepositoryURI = $RepositoryItem.SourceLocation
		if (!(Test-NetConnection -ComputerName $RepositoryURI.Host -Port 443 -InformationLevel Quiet -ErrorAction SilentlyContinue))
		{
			Write-Warning -Message "Repository $($RepositoryItem.Name) could not be contacted"
		}

		# Try anyway, maybe port is wrong, only first match is considered
		$FoundModule = Find-Module -Name $ModuleName -Repository $RepositoryItem -MinimumVersion $RequiredVersion -ErrorAction SilentlyContinue

		if ($FoundModule)
		{
			Write-Information -Tags "User" -MessageData "INFO: Module $ModuleName v$($ModuleStatus.Version.ToString()) is selected for download"
			break
		}
		# TODO: check for older version and ask for confirmation
	}

	if (!$FoundModule)
	{
		# Registering repository failed or no valid repository exists
		Write-Error -Category ObjectNotFound -TargetObject $Repositories `
			-Message "Module $ModuleName version >= v$RequiredVersion was not found in any of the following repositories: $RepositoryList"
		return $false
	}

	# Setup new choices
	$Accept.HelpMessage = $InfoMessage
	$Choices.Clear()
	$Choices += $Accept
	$Choices += $Deny

	# Either 'Update' or "Install" needed for additional work
	[string] $InstallType = ""

	if ($TargetVersion)
	{
		Write-Warning -Message "$ModuleName module version v$($TargetVersion.ToString()) is out of date, recommended version is v$RequiredVersion"

		$Title = "Recommended module out of date"
		$Question = "Update $ModuleName module now?"
		$Decision = $Host.UI.PromptForChoice($Title, $Question, $Choices, $Default)

		if ($Decision -eq $Default)
		{
			# TODO: splatting for parameters
			# Check if older version is user installed
			if (Get-InstalledModule -Name $ModuleName -ErrorAction Ignore)
			{
				$InstallType = "Update"
				Write-Information -Tags "User" -MessageData "INFO: Updating module $($FoundModule.Name) to v$($FoundModule.Version)"

				# In PowerShellGet versions 2.0.0 and above, the default is CurrentUser, which does not require elevation for install.
				# In PowerShellGet 1.x versions, the default is AllUsers, which requires elevation for install.
				# NOTE: for version 1.0.1 -Scope parameter is not recognized, we'll skip it for very old version
				# TODO: need to test compatible parameters for outdated Windows PowerShell
				if ($PowerShellGetVersion -gt "2.0.0")
				{
					Update-Module -InputObject $FoundModule -Scope AllUsers
				}
				else
				{
					Update-Module -InputObject $FoundModule
				}
			}
			else # Shipped with system
			{
				$InstallType = "Install"
				Write-Information -Tags "User" -MessageData "INFO: Installing module $($FoundModule.Name) v$($FoundModule.Version)"

				# Need force to install side by side, update not possible
				if ($PowerShellGetVersion -gt "2.0.0")
				{
					Install-Module -InputObject $FoundModule -AllowPrerelease:$AllowPrerelease -Scope AllUsers -Force
				}
				else
				{
					Install-Module -InputObject $FoundModule -Force
				}
			}
		}
	}
	else # Module not present
	{
		Write-Warning -Message "$ModuleName module minimum version v$RequiredVersion is recommended but not installed"

		$Title = "Recommended module not installed$ConnectionStatus"
		$Question = "Install $ModuleName module now?"
		$Decision = $Host.UI.PromptForChoice($Title, $Question, $Choices, $Default)

		if ($Decision -eq $Default)
		{
			$InstallType = "Install"
			Write-Information -Tags "User" -MessageData "INFO: Installing module $($FoundModule.Name) v$($FoundModule.Version)"

			if ($PowerShellGetVersion -gt "2.0.0")
			{
				Install-Module -InputObject $FoundModule -Scope AllUsers -AllowPrerelease:$AllowPrerelease
			}
			else
			{
				# TODO: AllowPrerelease may not work here
				Install-Module -InputObject $FoundModule
			}
		}
	}

	# If user choose default action, check if installation was success
	if ($Decision -eq $Default)
	{
		Write-Debug -Message "[$($MyInvocation.InvocationName)] Checking if $ModuleName install or update was successful"
		[PSModuleInfo] $ModuleStatus = Get-Module -FullyQualifiedName $ModuleFullName -ListAvailable

		if ($ModuleStatus)
		{
			Write-Information -Tags "User" -MessageData "INFO: Module $ModuleName v$($ModuleStatus.Version.ToString()) is installed"

			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Loading module $ModuleName v$($ModuleStatus.Version.ToString()) into session"
			# Replace old module with module in current session
			Remove-Module -Name $ModuleName
			Import-Module -Name $ModuleName

			# Finishing work, update as needed
			switch ($ModuleName)
			{
				"posh-git"
				{
					Write-Information -Tags "User" -MessageData "INFO: Adding $ModuleName $($ModuleStatus.Version.ToString()) to profile"
					Add-PoshGitToProfile -AllHosts
				}
			}

			return $true
		}
	}

	# Installation/update failed or user refused to do so
	Write-Error -Category NotInstalled -TargetObject $ModuleStatus `
		-Message "Module $ModuleName v$RequiredVersion not installed"

	return $false
}

<#
.SYNOPSIS
Test if recommended packages are installed
.DESCRIPTION
Test if recommended and up to date packages are installed, if not user is
prompted to install or update them.
Outdated or missing packages can cause strange issues, this function ensures latest packages are
installed and in correct order, taking into account failures that can happen while
installing or updating packages
.PARAMETER ProviderFullName
Hash table ProviderName, Version representing minimum required module
.PARAMETER Name
Hash table ProviderName, Version representing minimum required module
.PARAMETER ProviderName
Hash table ProviderName, Version representing minimum required module
.PARAMETER Location
Repository name from which to download packages such as NuGet,
if repository is not registered user is prompted to register it
.PARAMETER Trusted
If the supplied repository needs to be registered InstallationPolicy specifies
whether repository is trusted or not.
this parameter is used only if repository is not registered
.PARAMETER InfoMessage
Optional information displayable to user for choice help message
.EXAMPLE
Initialize-Provider @{ ModuleName = "PackageManagement"; ModuleVersion = "1.4.7" } -Repository "powershellgallery.com"
.INPUTS
None. You cannot pipe objects to Initialize-Provider
.OUTPUTS
None.
.NOTES
Before updating PowerShellGet or PackageManagement, you should always install the latest Nuget provider
#>
function Initialize-Provider
{
	[OutputType([bool])]
	[CmdletBinding(PositionalBinding = $false)]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[hashtable] $ProviderFullName,

		[Parameter()]
		[string] $Name = "nuget.org",

		[Parameter()]
		[ValidatePattern("[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)")]
		[uri] $Location = "https://api.nuget.org/v3/index.json", # TODO: array https://www.nuget.org/api/v2 (used by PSGallery?)

		[Parameter()] # TODO: switch also for modules
		[switch] $Trusted,

		[Parameter()]
		[string] $InfoMessage = "Accept operation"
	)

	begin
	{
		# User prompt default values
		[int32] $Default = 0
		[System.Management.Automation.Host.ChoiceDescription[]] $Choices = @()
		$Accept = [System.Management.Automation.Host.ChoiceDescription]::new("&Yes")
		$Deny = [System.Management.Automation.Host.ChoiceDescription]::new("&No")
		$Deny.HelpMessage = "Skip operation"
	}
	process
	{
		Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

		# Validate module specification
		if (!($ProviderFullName.Count -ge 2 -and
				($ProviderFullName.ContainsKey("ModuleName") -and $ProviderFullName.ContainsKey("ModuleVersion"))))
		{
			Write-Error -Category InvalidArgument -TargetObject $ProviderFullName `
				-Message "ModuleSpecification parameter for: $($ProviderFullName.ModuleName) is not valid"
			return $false
		}

		# Get required provider package from input
		[string] $ProviderName = $ProviderFullName.ModuleName
		[version] $RequiredVersion = $ProviderFullName.ModuleVersion

		Write-Debug -Message "[$($MyInvocation.InvocationName)] Checking if provider $ProviderName is installed and what version"

		# Highest version present on system if any
		[version] $TargetVersion = Get-PackageProvider -Name $ProviderName -ListAvailable |
		Sort-Object -Property Version | Select-Object -Last 1 -ExpandProperty Version

		if ($TargetVersion)
		{
			if ($TargetVersion -ge $RequiredVersion)
			{
				# Up to date
				Write-Information -Tags "User" -MessageData "INFO: Installed provider $ProviderName v$TargetVersion meets >= v$RequiredVersion"
				return $true
			}

			Write-Debug -Message "[$($MyInvocation.InvocationName)] Provider $ProviderName v$TargetVersion found"
		}

		# Check requested package source is registered
		Write-Debug -Message "[$($MyInvocation.InvocationName)] Checking if package source $ProviderName is registered"

		# Package source name only list
		[string] $SourcesList = ""

		# Available package sources
		[PSCustomObject[]] $PackageSources = Get-PackageSource -Name $Name -ProviderName $ProviderName -ErrorAction SilentlyContinue

		if ($PackageSources)
		{
			$SourcesList = $ProviderName
		}
		else
		{
			# Setup choices
			$Accept.HelpMessage = "Add a package source for a specified package provider"
			$Choices += $Accept
			$Choices += $Deny

			$Title = "Package source $ProviderName not registered"
			$Question = "Register $ProviderName package source now?"
			$Decision = $Host.UI.PromptForChoice($Title, $Question, $Choices, $Default)

			if ($Decision -eq $Default)
			{
				Write-Information -Tags "User" -MessageData "INFO: Registering package source $ProviderName"
				# Register package source to be able to use it
				Register-PackageSource -Name $Name -ProviderName $ProviderName -Location $Location -Trusted:$Trusted

				$SourceObject = Get-PackageSource -Name $Name -ProviderName $ProviderName -ErrorAction SilentlyContinue

				if ($SourceObject)
				{
					$PackageSources += $SourceObject
					$IsTrusted = "UnTrusted"

					if ($PackageSources[0].IsTrusted)
					{
						$IsTrusted = "Trusted"
					}

					Write-Verbose -Message "[$($MyInvocation.InvocationName)] Package source $ProviderName is registered and $IsTrusted"
				}
				# else error should be displayed
			}
			else
			{
				# Use default registered package sources
				$PackageSources = Get-PackageSource
			}

			if (!$PackageSources)
			{
				# Registering repository failed or no valid package source exists
				Write-Error -Category ObjectNotFound -TargetObject $PackageSources `
					-Message "No registered package source exist"
				return $false
			}
			else
			{
				Write-Debug -Message "[$($MyInvocation.InvocationName)] Constructing list of package sources for display"

				# Construct list for display on single line
				foreach ($SourceItem in $PackageSources)
				{
					$SourcesList += $SourceItem.Name
					$SourcesList += ", "
				}

				# TODO: use $foreach, anyway it doesn't work
				$SourcesList.TrimEnd(", ")
			}
		}

		# No need to specify type of repository, it's explained by user action
		Write-Information -Tags "User" -MessageData "INFO: Using following package sources: $SourcesList"

		# Check if module could be downloaded
		# [Microsoft.PackageManagement.Packaging.SoftwareIdentity]
		[PSCustomObject] $FoundProvider = $null
		Write-Debug -Message "[$($MyInvocation.InvocationName)] Checking if $ProviderName provider version >= v$RequiredVersion could be downloaded"

		foreach ($SourceItem in $PackageSources)
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Checking repository $SourceItem for updates"

			[uri] $SourceURI = $SourceItem.Location
			if (!(Test-NetConnection -ComputerName $SourceURI.Host -Port 443 -InformationLevel Quiet -ErrorAction SilentlyContinue))
			{
				Write-Warning -Message "Package source $($SourceItem.Name) could not be contacted"
			}

			# Try anyway, maybe port is wrong, only first match is considered
			$FoundProvider = Find-PackageProvider -Name $ProviderName -Source $Location `
				-MinimumVersion $RequiredVersion -IncludeDependencies -ErrorAction SilentlyContinue

			if (!$FoundProvider)
			{
				# Try with Find-Package
				$FoundProvider = Find-Package -Name $ProviderName -Source $SourceItem.Name -IncludeDependencies `
					-MinimumVersion $RequiredVersion -AllowPrereleaseVersions -ErrorAction SilentlyContinue
			}

			if ($FoundProvider)
			{
				Write-Information -Tags "User" -MessageData "INFO: $FoundProvider provider v$($FoundProvider.Version.ToString()) is selected for download"
				break
			}

			# TODO: else check for older version and ask for confirmation
		}

		if (!$FoundProvider)
		{
			if ($PSVersionTable.PSEdition -eq "Core")
			{
				Write-Warning -Message "$ProviderName was not found because of a known issue with PowerShell Core"
				Write-Information -Tags "User" -MessageData "INFO: https://github.com/OneGet/oneget/issues/360"
				return $false
			}

			# Registering repository failed or no valid repository exists
			Write-Error -Category ObjectNotFound -TargetObject $PackageSources `
				-Message "$ProviderName provider version >= v$RequiredVersion was not found in any of the following package sources: $SourcesList"
			return $false
		}

		# Setup prompt
		if (!$TargetVersion)
		{
			$Title = "Required package provider is not installed"
			$Question = "Update $ProviderName provider now?"
			Write-Warning -Message "$ProviderName provider minimum version v$RequiredVersion is required but not installed"
		}
		else
		{
			$Title = "Required package provider is out of date"
			$Question = "Install $ProviderName provider now?"
			Write-Warning -Message "$ProviderName provider version v$($TargetVersion.ToString()) is out of date, required version is v$RequiredVersion"
		}

		$Decision = $Host.UI.PromptForChoice($Title, $Question, $Choices, $Default)

		if ($Decision -eq $Default)
		{
			Write-Information -Tags "User" -MessageData "INFO: Installing $($FoundProvider.Name) provider v$($FoundProvider.Version.ToString())"
			Install-PackageProvider $FoundProvider.Name -Source $FoundProvider.Source

			[version] $NewVersion = Get-PackageProvider -Name $FoundProvider.Name |
			Sort-Object -Property Version | Select-Object -Last 1 -ExpandProperty Version

			if ($NewVersion -gt $TargetVersion)
			{
				Write-Information -Tags "User" -MessageData "INFO: $ProviderName provider v$NewVersion is installed"
				return $true
			}
			# else error should be shown
		}
		else
		{
			# User refused default action
			# TODO: should this be error?
			Write-Warning -Message "$ProviderName provider not installed"
		}

		return $false
	} # process
}

<#
.SYNOPSIS
Test and print system requirements required for this project
.DESCRIPTION
Initialize-Project is designed for "Windows Firewall Ruleset", it first prints a short watermark,
tests for OS, PowerShell version and edition, Administrator mode, NET Framework version, checks if
required system services are started and recommended modules installed.
If not the function may exit and stop executing scripts.
.PARAMETER Check
true or false to check or not to check
note that this parameter is managed by project settings
.EXAMPLE
Initialize-Project
.INPUTS
None. You cannot pipe objects to Initialize-Project
.OUTPUTS
None. Error or warning message is shown if check failed, system info otherwise.
.NOTES
TODO: learn required NET version by scanning scripts (ie. adding .COMPONENT to comments)
TODO: learn repo dir automatically (using git?)
TODO: we don't use logs in this module
TODO: remote check not implemented
#>
function Initialize-Project
{
	[OutputType([void])]
	param (
		[Parameter()]
		[switch] $NoProjectCheck = !$ProjectCheck,

		[Parameter()]
		[switch] $NoModulesCheck = !$ModulesCheck,

		[Parameter()]
		[switch] $NoServicesCheck = !$ServicesCheck
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

	# disabled when running scripts from SetupFirewall.ps1 script
	if ($NoProjectCheck)
	{
		Write-Debug -Message "[$($MyInvocation.InvocationName)] Project initialization skipped"
		return
	}

	# Print watermark
	Write-Output ""
	Write-Output "Windows Firewall Ruleset v$($ProjectVersion.ToString())"
	Write-Output "Copyright (C) 2019, 2020 metablaster zebal@protonmail.ch"
	Write-Output "https://github.com/metablaster/WindowsFirewallRuleset"
	Write-Output ""

	Write-Information -Tags "User" -MessageData "INFO: Checking operating system"

	# Check operating system
	$OSPlatform = [System.Environment]::OSVersion.Platform
	[version] $TargetOSVersion = [System.Environment]::OSVersion.Version
	[version] $RequiredOSVersion = "10.0"

	if (!(($OSPlatform -eq "Win32NT") -and ($TargetOSVersion -ge $RequiredOSVersion)))
	{
		Write-Error -Category OperationStopped -TargetObject $TargetOSVersion `
			-Message "Minimum required operating system is 'Win32NT $($RequiredOSVersion.ToString())' but '$OSPlatform $($TargetOSVersion.ToString()) present"
		exit
	}

	Write-Information -Tags "User" -MessageData "INFO: Checking elevation"

	# Check if in elevated PowerShell
	$Principal = New-Object -TypeName Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

	if (!$Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
	{
		Write-Error -Category PermissionDenied -TargetObject $Principal `
			-Message "Elevation required, please open PowerShell as Administrator and try again"
		exit
	}

	Write-Information -Tags "User" -MessageData "INFO: Checking OS edition"

	# Check OS is not Home edition
	$OSEdition = Get-WindowsEdition -Online | Select-Object -ExpandProperty Edition

	if ($OSEdition -like "*Home*")
	{
		Write-Error -Category OperationStopped -TargetObject $OSEdition `
			-Message "Home editions of Windows don't have Local Group Policy"
		exit
	}

	Write-Information -Tags "User" -MessageData "INFO: Checking PowerShell edition"

	# Check PowerShell edition
	$PowerShellEdition = $PSVersionTable.PSEdition
	# Check PowerShell version
	[version] $RequiredPSVersion = "5.1.0"
	[version] $TargetPSVersion = $PSVersionTable.PSVersion

	if ($PowerShellEdition -eq "Core")
	{
		$RequiredPSVersion = "7.0.3"
		Write-Warning -Message "Remote firewall administration with PowerShell Core is not implemented"
	}
	else
	{
		Write-Warning -Message "Remote firewall administration with PowerShell Desktop is partially implemented"

	}

	Write-Information -Tags "User" -MessageData "INFO: Checking PowerShell version"
	if ($TargetPSVersion -lt $RequiredPSVersion)
	{
		if ($TargetPSVersion.Major -lt $RequiredPSVersion.Major)
		{
			# Core 6 is fine
			if (($PowerShellEdition -eq "Desktop") -or (($RequiredPSVersion.Major - $TargetPSVersion.Major) -gt 1))
			{
				Write-Error -Category OperationStopped -TargetObject $TargetPSVersion `
					-Message "Required PowerShell $PowerShellEdition is v$($RequiredPSVersion.ToString()) but v$($TargetPSVersion.ToString()) present"
				exit
			}
		}

		Write-Warning -Message "Recommended PowerShell $PowerShellEdition is v$($RequiredPSVersion.ToString()) but v$($TargetPSVersion.ToString()) present"
	}

	# Check NET Framework version
	# NOTE: this check is not required except for updating requirements as needed
	if ($Develop -and ($PowerShellEdition -eq "Desktop"))
	{
		Write-Information -Tags "User" -MessageData "INFO: Checking .NET version"

		# Now that OS and PowerShell is OK we can use these functions
		$NETFramework = Get-NetFramework
		[version] $TargetNETVersion = $NETFramework |
		Sort-Object -Property Version | Select-Object -Last 1 -ExpandProperty Version

		[version] $RequiredNETVersion = "3.5.0"

		if (!$TargetNETVersion -or ($TargetNETVersion -lt $RequiredNETVersion))
		{
			Write-Error -Category OperationStopped -TargetObject $TargetNETVersion `
				-Message "Minimum required .NET Framework version is v$($RequiredNETVersion.ToString()) but v$($TargetNETVersion.ToString()) present"
			exit
		}
	}

	if (!$NoServicesCheck)
	{
		Write-Information -Tags "User" -MessageData "INFO: Checking system services"

		# These services are minimum required
		if (!(Initialize-Service @("lmhosts", "LanmanWorkstation", "LanmanServer"))) { exit }

		# NOTE: remote administration needs this service, see Enable-PSRemoting cmdlet
		# NOTE: some tests depend on this service, project not ready for remoting
		if ($develop -and ($PolicyStore -ne [System.Environment]::MachineName))
		{
			if (Initialize-Service "WinRM") { exit }
		}
	}

	Write-Information -Tags "User" -MessageData "INFO: Checking git"

	# Git is recommended for version control and by posh-git module
	[string] $RequiredGit = "2.28.0"
	Set-Variable -Name GitInstance -Scope Script -Option Constant -Value `
	$(Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue)

	if ($GitInstance)
	{
		[version] $TargetGit = $GitInstance.Version

		if ($TargetGit -lt $RequiredGit)
		{
			Write-Warning -Message "Git version v$($TargetGit.ToString()) is out of date, recommended version is v$RequiredGit"
			Write-Information -Tags "Project" -MessageData "INFO: Please visit https://git-scm.com to download and update"
		}
	}
	else
	{
		Write-Warning -Message "Git in the PATH minimum version v$($RequiredGit.ToString()) is recommended but missing"
		Write-Information -Tags "User" -MessageData "INFO: Please verify PATH or visit https://git-scm.com to download and install"
	}

	if (!$NoModulesCheck)
	{
		Write-Information -Tags "User" -MessageData "INFO: Checking providers"

		[string] $Repository = "NuGet"

		# NOTE: Before updating PowerShellGet or PackageManagement, you should always install the latest Nuget provider
		# NOTE: Updating PackageManagement and PowerShellGet requires restarting PowerShell to switch to the latest version.
		if (!(Initialize-Provider @{ ModuleName = "NuGet"; ModuleVersion = "3.0.0" } `
					-InfoMessage "Before updating PowerShellGet or PackageManagement, you should always install the latest Nuget provider")) { exit }

		Write-Information -Tags "User" -MessageData "INFO: Checking modules"

		# PowerShellGet >= 2.2.4 is required otherwise updating modules might fail
		# NOTE: PowerShellGet has a dependency on PackageManagement, it will install it if needed
		# For systems with PowerShell 5.0 (or greater) PowerShellGet and PackageManagement can be installed together.
		if (!(Initialize-Module @{ ModuleName = "PowerShellGet"; ModuleVersion = "2.2.4" } -Repository $Repository `
					-InfoMessage "PowerShellGet >= 2.2.4 is required otherwise updating modules might fail")) { exit }

		# PackageManagement >= 1.4.7 is required otherwise updating modules might fail
		if (!(Initialize-Module @{ ModuleName = "PackageManagement"; ModuleVersion = "1.4.7" } -Repository $Repository)) { exit }

		# posh-git >= 1.0.0-beta4 is recommended for better git experience in PowerShell
		if (Initialize-Module @{ ModuleName = "posh-git"; ModuleVersion = "0.7.3" } -Repository $Repository -AllowPrerelease `
				-InfoMessage "posh-git is recommended for better git experience in PowerShell" ) { }

		# PSScriptAnalyzer >= 1.19.1 is required otherwise code will start missing while editing
		if (!(Initialize-Module @{ ModuleName = "PSScriptAnalyzer"; ModuleVersion = "1.19.1" } -Repository $Repository `
					-InfoMessage "PSScriptAnalyzer >= 1.19.1 is required otherwise code will start missing while editing" )) { exit }

		# Pester is required to run pester tests
		if (!(Initialize-Module @{ ModuleName = "Pester"; ModuleVersion = "5.0.3" } -Repository $Repository `
					-InfoMessage "Pester is required to run pester tests" )) { }
	}

	# Everything OK, print environment status
	# TODO: CIM may not always work
	$OSCaption = Get-CimInstance -Class Win32_OperatingSystem |
	Select-Object -ExpandProperty Caption

	Write-Information -Tags "User" -MessageData "INFO: Checking project requirements successful"

	Write-Output ""
	Write-Output "System:`t`t $OSCaption v$($TargetOSVersion.ToString())"
	Write-Output "Environment:`t PowerShell $PowerShellEdition v$($TargetPSVersion)"
	Write-Output ""
}

#
# Function exports
#

Export-ModuleMember -Function Initialize-Project
Export-ModuleMember -Function Initialize-Service
Export-ModuleMember -Function Initialize-Module
Export-ModuleMember -Function Initialize-Provider
