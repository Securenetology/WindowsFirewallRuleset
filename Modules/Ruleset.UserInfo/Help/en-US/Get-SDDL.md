---
external help file: Ruleset.UserInfo-help.xml
Module Name: Ruleset.UserInfo
online version: https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.UserInfo/Help/en-US/Get-SDDL.md
schema: 2.0.0
---

# Get-SDDL

## SYNOPSIS

Generate SDDL string of multiple usernames or/and groups on a given domain

## SYNTAX

### Group

```powershell
Get-SDDL [-UserNames <String[]>] -UserGroups <String[]> [-ComputerName <String>] [-CIM] [<CommonParameters>]
```

### User

```powershell
Get-SDDL -UserNames <String[]> [-ComputerName <String>] [-CIM] [<CommonParameters>]
```

## DESCRIPTION

Get SDDL string single or multiple user names and/or user groups on a single target computer

## EXAMPLES

### EXAMPLE 1

```powershell
[string[]] $Users = "User"
PS> [string] $Server = COMPUTERNAME
PS> [string[]] $Groups = "Users", "Administrators"
```

PS\> $UsersSDDL1 = Get-SDDL -User $Users -Group $Groups
PS\> $UsersSDDL2 = Get-SDDL -User $Users -Machine $Server
PS\> $UsersSDDL3 = Get-SDDL -Group $Groups

### EXAMPLE 2

```powershell
$NewSDDL = Get-SDDL -Domain "NT AUTHORITY" -User "System"
```

## PARAMETERS

### -UserNames

Array of users for which to generate SDDL string

```yaml
Type: System.String[]
Parameter Sets: Group
Aliases: User

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: System.String[]
Parameter Sets: User
Aliases: User

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserGroups

Array of user groups for which to generate SDDL string

```yaml
Type: System.String[]
Parameter Sets: Group
Aliases: Group

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName

Single domain or computer such as remote computer name or builtin computer domain

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: Computer, Server, Domain, Host, Machine

Required: False
Position: Named
Default value: [System.Environment]::MachineName
Accept pipeline input: False
Accept wildcard characters: False
```

### -CIM

Whether to contact CIM server (required for remote computers)

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

### None. You cannot pipe objects to Get-SDDL

## OUTPUTS

### [string] SDDL for given accounts or/and group for given domain

## NOTES

CIM switch is not supported on PowerShell Core, meaning contacting remote computers
is supported only on Windows PowerShell

## RELATED LINKS
