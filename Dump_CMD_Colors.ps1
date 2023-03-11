<#
.Synopsis
This script prints colors used by `cmd`.
.Description
This script goes through registry of cmd containing terminal colors to print their value in user-readable format.
.Parameter Format
Specifies which format should be used to print individual values.
`hex`       - `abcdef`
`HEX`       - `ABCDEF`
`csv`/`CSV` - `171, 205, 239`
.Parameter Padded
If format contains separators then the components will be aligned with padding.
Example:
`  3,  20, 100`
` 14, 120, 240`
`255,  24,  16`
.Parameter Colored
Use corresponding terminal colors to print the values.
Darker colors will have light background.
Note that this parameter uses `Write-Host` method, so in this case the call can't be used with `ForEach-Object`.
.Parameter NoBackground
Colors will not be printed with any background.
.Example
.\Dump_CMD_Colors HEX | % { "0x{0}" -f $_ }
# Prints all the values in HEXadecimal format with `0x` in prefix:
0x000000
0x0000FF
0x00FF00
...
.Example
.\Dump_CMD_Colors csv -Padded | % { "rgb({0})" -f $_ }
# Prints all the values as `rgb(  r,   g,   b)`
rgb(  0,   0,   0)
rgb(  0,   0, 255)
rgb(  0, 255,   0)
...
.Example
.\Dump_CMD_Colors hex -Colored
# Prints all the values in hexadecimal format where each value has corresponding terminal color.
# Note that `-Colored` parameter uses `Write-Host` method, so in this case it can't be used with `ForEach-Object`.
#> 

param(
    [ValidateNotNullOrEmpty()]
    [ValidateSet("hex","HEX","csv","CSV",IgnoreCase = $false)]
    [string]$Format="HEX",
    [switch]$Padded,
    [switch]$Colored,
    [Alias("NoBG")]
    [switch]$NoBackground
)

$RegistryPath = "HKCU:\Console";
$RegistryKeyFormat = "ColorTable{0:d2}";

$OutputColorNames = "Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White";

$RGBPadding = 0;
if ($Padded) {
    $RGBPadding = 3;
}

function Get-ColorFormatter {
    switch -casesensitive ($Format) {
        "hex" {
            return { param([Int32]$Value) "{0:x6}" -f $Value }
        }
        "HEX" {
            return { param([Int32]$Value) "{0:X6}" -f $Value }
        }
        {("csv", "CSV").Contains($_)} {
            return { param([Int32]$Value) "{0}, {1}, {2}" -f ([string][math]::floor($Value / 256 / 256)).PadLeft($RGBPadding), ([string][math]::floor($Value / 256 % 256)).PadLeft($RGBPadding), ([string][math]::floor($Value % 256)).PadLeft($RGBPadding) }
        }
    }
    return { param([Int32]$Value) $Value }
}

function Write-ConsoleColor {
    param([Int32]$Value, [Int32]$Index)
    $Value = (($Value -shl 0x10) -band 0xFF0000) -bor (($Value) -band 0x00FF00) -bor (($Value -shr 0x10) -band 0x0000FF);
    $Formatter = Get-ColorFormatter;
    if ($Colored) {
        if ($NoBackground) {
            Write-Host $Formatter.Invoke($Value) -ForegroundColor $OutputColorNames[$Index];
            return;
        }
        Write-Host $Formatter.Invoke($Value) -ForegroundColor $OutputColorNames[$Index] -BackgroundColor $OutputColorNames[8 - [math]::floor($Index / 8) * 8];
        return;
    }
    Write-Output $Formatter.Invoke($Value);
    return;
}

for ($index = 0; $index -le 15; $index++) {
    $RegistryKey = $RegistryKeyFormat -f $index;
    $Value = [Int32](Get-ItemProperty -Path $RegistryPath | Select-Object -ExpandProperty $RegistryKey);
    Write-ConsoleColor $Value $Index;
}