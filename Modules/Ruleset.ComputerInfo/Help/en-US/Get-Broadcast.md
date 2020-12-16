---
external help file: Ruleset.ComputerInfo-help.xml
Module Name: Ruleset.ComputerInfo
online version: https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.ComputerInfo/Help/en-US/Get-Broadcast.md
schema: 2.0.0
---

# Get-Broadcast

## SYNOPSIS

Get broadcast addresses on the local machine

## SYNTAX

### Individual (Default)

```powershell
Get-Broadcast [-ExcludeHardware] [-IncludeVirtual] [-IncludeHidden] [-IncludeDisconnected] [<CommonParameters>]
```

### All

```powershell
Get-Broadcast [-IncludeAll] [-ExcludeHardware] [<CommonParameters>]
```

## DESCRIPTION

Return broadcast addresses, for each configured adapter.
This includes both physical and virtual adapters.
Returned broadcast addresses are only for IPv4

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Broadcast -IncludeAll
```

### EXAMPLE 2

```powershell
Get-Broadcast -IncludeAll -ExcludeHardware
```

## PARAMETERS

### -IncludeAll

Include all possible adapter types present on target computer

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeHardware

Exclude hardware/physical network adapters

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

### -IncludeVirtual

Whether to include virtual adapters

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Individual
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeHidden

Whether to include hidden adapters

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Individual
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDisconnected

Whether to include disconnected

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Individual
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

### None. You cannot pipe objects to Get-Broadcast

## OUTPUTS

### [ipaddress] Broadcast addresses

## NOTES

TODO: Some parameters most likely make no sense, otherwise we should return custom object,
separating addresses per adapter

## RELATED LINKS
