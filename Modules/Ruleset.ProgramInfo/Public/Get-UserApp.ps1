
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

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
Get store apps for specific user

.DESCRIPTION
Search installed store apps in userprofile for specific user account

.PARAMETER Name
Specifies the name of a particular package.
If specified, function returns results for this package only.
Wildcards are permitted.

.PARAMETER User
User name in form of:

- domain\user_name
- user_name@fqn.domain.tld
- user_name
- SID-string

.PARAMETER Domain
NETBIOS Computer name in form of "COMPUTERNAME"

.EXAMPLE
PS> Get-UserApp "User" -Domain "Server01"

.EXAMPLE
PS> Get-UserApp "Administrator"

.INPUTS
None. You cannot pipe objects to Get-UserApp

.OUTPUTS
[Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage] store app information object
[object] if using PowerShell Core which outputs deserialized object:
[Deserialized.Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage]

.NOTES
TODO: We should probably return custom object to be able to pipe to functions such as Get-AppSID
TODO: See also -AllUsers and other parameters in related links
TODO: Format.ps1xml not applied in Windows PowerShell

.LINK
https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.ProgramInfo/Help/en-US/Get-UserApp.md

.LINK
https://docs.microsoft.com/en-us/powershell/module/appx/get-appxpackage?view=win10-ps
#>
function Get-UserApp
{
	[CmdletBinding(
		HelpURI = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.ProgramInfo/Help/en-US/Get-UserApp.md")]
	[OutputType([Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage], [object])]
	param (
		[Parameter()]
		[SupportsWildcards()]
		[string] $Name = "*",

		[Parameter(Mandatory = $true)]
		[Alias("UserName")]
		[string] $User,

		[Parameter()]
		[Alias("ComputerName", "CN")]
		[string[]] $Domain = [System.Environment]::MachineName
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] ParameterSet = $($PSCmdlet.ParameterSetName):$($PSBoundParameters | Out-String)"

	# Replace localhost and dot with NETBIOS computer name
	$Domain = foreach ($Computer in $Domain)
	{
		if (($Computer -eq "localhost") -or ($Computer -eq "."))
		{
			[System.Environment]::MachineName
		}
		else
		{
			$Computer
		}
	}

	foreach ($Computer in $Domain)
	{
		if (Test-Computer $Computer)
		{
			if ($Computer -eq [System.Environment]::MachineName)
			{
				# TODO: PackageTypeFilter is not clear, why only "Bundle"?
				# TODO: show warning instead of error when failed (ex. in non elevated run check is Admin)
				$Apps = Get-AppxPackage -Name $Name -User $User -PackageTypeFilter Bundle
				$DomainPath = $env:SystemDrive
			}
			else
			{
				$Apps = Invoke-Command -Session $SessionInstance -ScriptBlock {
					Get-AppxPackage -Name $using:Name -User $using:User -PackageTypeFilter Bundle
				}

				[string] $SystemDrive = Get-CimInstance -Class Win32_OperatingSystem -CimSession $CimServer |
				Select-Object -ExpandProperty SystemDrive

				$SystemDrive = $SystemDrive.TrimEnd(":")
				$DomainPath = "\\$Computer\$SystemDrive`$\"
			}

			foreach ($App in $Apps)
			{
				# NOTE: This path will be missing for default apps on Windows server
				# It may also be missing in fresh installed OS before connecting to internet
				# TODO: See if "$_.Status" property can be used to determine if app is valid
				if (Test-Path -PathType Container -Path "$DomainPath\Users\$User\AppData\Local\Packages\$($App.PackageFamilyName)\AC")
				{
					# There is no Domain property, so add one, PSComputerName property is of no use here
					Add-Member -InputObject $App -PassThru -Type NoteProperty -Name Domain -Value $Domain
				}
				else
				{
					Write-Warning -Message "[$($MyInvocation.InvocationName)] Store app '$($App.Name)' is not installed by user '$User' or the app is missing"
					Write-Information -Tags $MyInvocation.InvocationName `
						-MessageData "INFO: To fix the problem let this user update all of it's apps in Windows store"
				}
			}
		} # if Test-Computer
	} # foreach Computer
}