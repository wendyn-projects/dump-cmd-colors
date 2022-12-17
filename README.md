# dump-cmd-colors
A script for dumping Window's `cmd` colors from registry.

This script goes through registry of `cmd` _containing terminal colors_ to print their value in user-readable format.

## Syntax
```cmd
.\Dump_CMD_Colors.ps1 [[-Format] <String>] [-Padded] [-Colored] [-NoBackground] [<CommonParameters>]
```

## Parameters

### Format \<String\>
```
    Specifies which format should be used to print individual values.
    `hex`       - `abcdef`
    `HEX`       - `ABCDEF`
    `csv`/`CSV` - `171, 205, 239`
```
### Padded [\<SwitchParameter\>]
```
    If format contains separators then the components will be aligned with padding.
    Example:
    `  3,  20, 100`
    ` 14, 120, 240`
    `255,  24,  16`
```

### Colored [\<SwitchParameter\>]
```
    Use corresponding terminal colors to print the values.
    Darker colors will have light background.
    Note that this parameter uses `Write-Host` method, so in this case the call can't be used with
    `ForEach-Object`.
```
### NoBackground [\<SwitchParameter\>]
```
    Colors will not be printed with any background.
```

## Examples
### Printing Colors in Hexadecimal Format
```ps
.\Dump_CMD_Colors HEX | % { "0x{0}" -f $_ }
```
Prints all the values in HEXadecimal format with `0x` in prefix:
```
0x000000
0x0000FF
0x00FF00
...
```
### Printing Colors as `rgb(...)`
```ps
.\Dump_CMD_Colors csv -Padded | % { "rgb({0})" -f $_ }
```
Prints all the values as `rgb(  r,   g,   b)`
```
rgb(  0,   0,   0)
rgb(  0,   0, 255)
rgb(  0, 255,   0)
...
```
### Printing Colors as Colored Text
```ps
.\Dump_CMD_Colors hex -Colored
```
Prints all the values in hexadecimal format where each value has corresponding terminal color.

Note that `-Colored` parameter uses `Write-Host` method, so in this case it can't be used with `ForEach-Object`.


## Extra Notes
To see the examples, type: `Get-Help .\Dump_CMD_Colors.ps1 -Examples`.

For more information, type: `Get-Help .\Dump_CMD_Colors.ps1 -Detailed`.

For technical information, type: `Get-Help .\Dump_CMD_Colors.ps1 -Full`.
