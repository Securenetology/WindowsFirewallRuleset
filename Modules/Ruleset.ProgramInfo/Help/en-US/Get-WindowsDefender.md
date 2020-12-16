---
external help file: Ruleset.ProgramInfo-help.xml
Module Name: Ruleset.ProgramInfo
online version: https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.ProgramInfo/Help/en-US/Get-WindowsDefender.md
schema: 2.0.0
---

# Get-WindowsDefender

## SYNOPSIS

Get installed Windows Defender

## SYNTAX

```powershell
Get-WindowsDefender [[-ComputerName] <String>] [<CommonParameters>]
```

## DESCRIPTION

Gets installation information about Windows defender.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-WindowsDefender COMPUTERNAME
```

## PARAMETERS

### -ComputerName

Computer name for which to list installed Windows Defender

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: Computer, Server, Domain, Host, Machine

Required: False
Position: 1
Default value: [System.Environment]::MachineName
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Get-WindowsDefender

## OUTPUTS

### [PSCustomObject] for installed Windows Defender, version and install paths

## NOTES

None.

## RELATED LINKS
