---
external help file: Ruleset.Initialize-help.xml
Module Name: Ruleset.Initialize
online version: https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Initialize/Help/en-US/Initialize-Module.md
schema: 2.0.0
---

# Initialize-Module

## SYNOPSIS

Update or install specified modules

## SYNTAX

```powershell
Initialize-Module [-FullyQualifiedName] <Hashtable> [-Repository <String>] [-URL <Uri>] [-InfoMessage <String>]
 [-Trusted] [-AllowPrerelease] [-Required] [<CommonParameters>]
```

## DESCRIPTION

Test if recommended and up to date module is installed, if not user is
prompted to install or update them.
Outdated or missing modules can cause strange issues, this function ensures latest modules are
installed and in correct order, taking into account failures that can happen while
installing or updating modules

## EXAMPLES

### EXAMPLE 1

```powershell
Initialize-Module @{ ModuleName = "PSScriptAnalyzer"; ModuleVersion = "1.19.1" }
```

Checks if PSScriptAnalyzer is up to date, if not user is prompted to update, and if repository
specified by default is not registered user is prompted to do that too.

### EXAMPLE 2

```powershell
Initialize-Module @{ ModuleName = "PackageManagement"; ModuleVersion = "1.4.7" } `
-Repository "PSGallery" -URL "https://www.powershellgallery.com/api/v2"
```

Checks if PackageManagement is up to date, if not user is prompted to update, and if repository
is not registered user is prompted to do that too.

## PARAMETERS

### -FullyQualifiedName

Hash table with a minimum ModuleName and ModuleVersion keys, in the form of ModuleSpecification

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository

Repository name from which to download module such as PSGallery,
if repository is not registered user is prompted to register it

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PSGallery
Accept pipeline input: False
Accept wildcard characters: False
```

### -URL

Repository location associated with repository name,
this parameter is used only if repository is not registered

```yaml
Type: System.Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Https://www.powershellgallery.com/api/v2
Accept pipeline input: False
Accept wildcard characters: False
```

### -InfoMessage

Help message used for default choice in host prompt

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Accept operation
Accept pipeline input: False
Accept wildcard characters: False
```

### -Trusted

If the supplied repository needs to be registered Trusted specifies
whether repository is trusted or not.
this parameter is used only if repository is not registered

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowPrerelease

whether to allow installing beta modules

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Required

Controls whether module initialization must succeed, if initialization fails execution stops,
otherwise only warning is generated

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Initialize-Module

## OUTPUTS

### [bool]

## NOTES

This function main purpose is automated development environment setup to be able to perform quick
setup on multiple computers and virtual operating systems, in cases such as frequent system restores
for the purpose of testing project code for many environment scenarios that end users may have.
It should be used in conjunction with the rest of a module "Ruleset.Initialize"

Before updating PowerShellGet or PackageManagement, you should always install the latest Nuget provider
Updating PackageManagement and PowerShellGet requires restarting PowerShell to switch to the latest version
TODO: Implement initializing for non Administrator users
TODO: installing post-git in same session while installing other modules may fail, and PS restart is required.

## RELATED LINKS
