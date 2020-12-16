---
external help file: Ruleset.Utility-help.xml
Module Name: Ruleset.Utility
online version: https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Utility/Help/en-US/Show-SDDL.md
schema: 2.0.0
---

# Show-SDDL

## SYNOPSIS

Show-SDDL returns SDDL based on "object" such as path, or registry entry

## SYNTAX

```powershell
Show-SDDL [-SDDL] <String> [<CommonParameters>]
```

## DESCRIPTION

TODO: add description

## EXAMPLES

### EXAMPLE 1

```powershell
see Test\Show-SDDL.ps1 for example
```

## PARAMETERS

### -SDDL

TODO: describe parameter

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string]

## OUTPUTS

### [string]

## NOTES

This function is used only for debugging and discovery of object SDDL, credits to link in description.
TODO: additional work on function to make it more universal, see if we can make use of it somehow, better help comment.

## RELATED LINKS

[https://blogs.technet.microsoft.com/ashleymcglone/2011/08/29/powershell-sid-walker-texas-ranger-part-1](https://blogs.technet.microsoft.com/ashleymcglone/2011/08/29/powershell-sid-walker-texas-ranger-part-1)
