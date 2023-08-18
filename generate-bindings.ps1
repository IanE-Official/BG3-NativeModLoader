#Requires -Version 5

# args
param (
    [Parameter(Mandatory)][string]$target_path,
    [string]$dumpbin_path
)


# @@ locate dumpbin
$vswhere = ${env:ProgramFiles(x86)} + '\Microsoft Visual Studio\Installer\vswhere.exe'
$dumpbin
if (!(Test-Path $vswhere)) {
    $dumpbin = $dumpbin_path
}
else {
    $dumpbin = (& $vswhere -latest -property installationPath) + '\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe'
}


# @@ test paths
"`n>>> testing target"
$target = gci $target_path
if (!(Test-Path $target)) {
    Write-Error "Target file not found! Provide valid path to target file as the first argument"
    exit 1
}
$target.FullName

"`n>>> testing dumpbin.exe"
$dumpbin = Resolve-Path $dumpbin
if (!(Test-Path $dumpbin)) {
    Write-Error "dumpbin.exe not found! This script uses dumpbin.exe to generate /EXPORTS table. `nProvide valid path to dumpbin.exe as the second argument"
    exit 1
}
$dumpbin = $dumpbin.Path
$dumpbin


# @@ dump exports
"`n>>> dumping exports"
$output = $(& $dumpbin /exports $target)
$exports = @()
foreach ($line in $output) {
    if ($line -match '\s*(\d+)\s+\w+\s(\d)\w+\s(\w+)') {
        $exports += , $matches[3]
    }
}
"found $($exports.Count) exports"

"`n---------`n"
$exports


# @@ generate bindings
"`n>>> generating bindings"
$JmpTbl = @(".code")
$DefTbl = @("EXPORTS")

# header
$FuncTblVarName = "ImportFuncTbl"
$JmpTbl += "extern $($FuncTblVarName):QWORD"

for ($i = 0; $i -lt $exports.Count; $i++) {
    "@$($i + 1)`t$($exports[$i])"

    $JmpTbl += "$($exports[$i]) PROC"
    $JmpTbl += "`tjmp $FuncTblVarName[$($i) * 8]"
    $JmpTbl += "$($exports[$i]) ENDP"

    $DefTbl += "$($exports[$i]) @$($i + 1)"
}

# tail
$JmpTbl += "end"


# @@ write bindings
"`n>>> writing bindings"
$JmpTbl | Out-File "$PSScriptRoot/include/jmp.asm" -Encoding ascii
$DefTbl | Out-File "$PSScriptRoot/include/exports.def" -Encoding ascii
"`n>>> done"