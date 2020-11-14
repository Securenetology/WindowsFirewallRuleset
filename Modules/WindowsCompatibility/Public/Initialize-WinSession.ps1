
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
Initialize the connection to the compatibility session.

.DESCRIPTION
Initialize the connection to the compatibility session.
By default the compatibility session will be created on the localhost using the 'Microsoft.PowerShell' configuration.
On subsequent calls, if a session matching the current specification is found,
it will be returned rather than creating a new session.
If a matching session is found, but can't be used,
it will be closed and a new session will be retrieved.

This command is called by the other commands in this module so you will rarely call this command directly.

.EXAMPLE
PS> Initialize-WinSession

Initialize the default compatibility session.

.EXAMPLE
PS> Initialize-WinSession -ComputerName localhost -ConfigurationName Microsoft.PowerShell

Initialize the compatibility session with a specific computer name and configuration

.INPUTS
None. You cannot pipe objects to Initialize-WinSession

.OUTPUTS
System.Management.Automation.Runspaces.PSSession

.NOTES
None.
TODO: Update Copyright and start implementing module function
TODO: Update HelpURI
#>
function Initialize-WinSession
{
	[CmdletBinding()]
	[OutputType([System.Management.Automation.Runspaces.PSSession])]
	Param (

		# If you don't want to use the default compatibility session, use
		# this parameter to specify the name of the computer on which to create
		# the compatibility session.
		[Parameter(Mandatory = $false, Position = 0)]
		[String]
		[Alias("Cn")]
		$ComputerName,

		# Specifies the configuration to connect to when creating the compatibility session
		# (Defaults to 'Microsoft.PowerShell')
		[Parameter()]
		[String]
		$ConfigurationName,

		# The credential to use when connecting to the target machine/configuration
		[Parameter()]
		[PSCredential]
		$Credential,

		# If present, the specified session object will be returned
		[Parameter()]
		[Switch]
		$PassThru
	)

	[bool] $verboseFlag = $PSBoundParameters['Verbose']

	if ($ComputerName -eq ".")
	{
		$ComputerName = "localhost"
	}

	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Initializing the compatibility session on host '$ComputerName'."

	if ($ComputerName)
	{
		$script:SessionComputerName = $ComputerName
	}
	else
	{
		$ComputerName = $script:SessionComputerName
	}

	if ($ConfigurationName)
	{
		$script:SessionConfigurationName = $ConfigurationName
	}
	else
	{
		$ConfigurationName = $script:SessionConfigurationName
	}

	if ($Credential)
	{
		$script:SessionName = "wincompat-$ComputerName-$($Credential.UserName)"
	}
	else
	{
		$script:SessionName = "wincompat-$ComputerName-$([environment]::UserName)"
	}

	Write-Verbose -Message "[$($MyInvocation.InvocationName)] The compatibility session name is '$script:SessionName'."

	$session = Get-PSSession | Where-Object {
		$_.ComputerName -eq $ComputerName -and
		$_.ConfigurationName -eq $ConfigurationName -and
		$_.Name -eq $script:SessionName
	} | Select-Object -First 1

	# Deal with the possibilities of multiple sessions. This might arise
	# from the user hitting ctrl-C. We'll make the assumption that the
	# first one returned is the correct one and we'll remove the rest.
	$session, $rest = $session
	if ($rest)
	{
		foreach ($s in $rest)
		{
			Remove-PSSession $s
		}
	}

	if ($session -and $session.State -ne "Opened")
	{
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Removing closed compatibility session."
		Remove-PSSession $session
		$session = $null
	}

	if (-not $session)
	{
		$newPSSessionParameters = @{
			Verbose = $verboseFlag
			ComputerName = $ComputerName
			Name = $script:sessionName
			ConfigurationName = $configurationName
			ErrorAction = "Stop"
		}
		if ($Credential)
		{
			$newPSSessionParameters.Credential = $Credential
		}
		if ($ComputerName -eq "localhost" -or $ComputerName -eq [environment]::MachineName)
		{
			$newPSSessionParameters.EnableNetworkAccess = $true
		}

		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Created new compatibility session on host '$computername'"
		$session = New-PSSession @newPSSessionParameters | Select-Object -First 1
		if ($session.ComputerName -eq "localhost")
		{
			$usingPath = (Get-Location).Path
			Invoke-Command $session { Set-Location $using:usingPath }
		}
	}
	else
	{
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Reusing the existing compatibility session; 'host = $script:SessionComputerName'."
	}

	if ($PassThru)
	{
		return $session
	}
}
