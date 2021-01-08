---
external help file: Microsoft.VisualStudio.Setup.PowerShell.dll-Help.xml
Module Name: VSSetup
online version: https://github.com/Microsoft/vssetup.powershell/raw/master/docs/VSSetup/Get-VSSetupInstance.md
schema: 2.0.0
---

# Get-VSSetupInstance

## SYNOPSIS

Enumerates instances of Visual Studio and related products.

## SYNTAX

### All (Default)

```powershell
Get-VSSetupInstance [-All] [-Prerelease] [<CommonParameters>]
```

### Path

```powershell
Get-VSSetupInstance [-Path] <String[]> [<CommonParameters>]
```

### LiteralPath

```powershell
Get-VSSetupInstance -LiteralPath <String[]> [<CommonParameters>]
```

## DESCRIPTION

Enumerates instances of Visual Studio and related products. By default, instances with fatal errors
are not returned by you can pass `-All` to enumerate them as well.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-VSSetupInstance -All
```

Enumerates all instances of Visual Studio and related products even if a fatal error was raised
during the last operation.

### Example 2

```powershell
PS C:\> Get-VSSetupInstance 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community'
```

Gets the instance for the product installed to the given directory.

## PARAMETERS

### -All

Enumerate all instances of Visual Studio - even those with fatal errors.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralPath

The path to the product installation directory. Wildcards are not supported.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases: PSPath

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

The path to the product installation directory. Wildcards are supported.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Prerelease

Also show prereleases / previews. By default, only releases are shown.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction,
-InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and
-WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

One or more paths to product installation directories.

## OUTPUTS

### Microsoft.VisualStudio.Setup.Instance

Information about each instance enumerated.

## NOTES

## RELATED LINKS
