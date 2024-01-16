Remove-Item $PSScriptRoot/build -Recurse -Force -ErrorAction:SilentlyContinue -Confirm:$False | Out-Null
& cmake -B $PSScriptRoot/build -S $PSScriptRoot --preset=REL -DPLUGIN_MODE:BOOL=TRUE -DCMAKE_TOOLCHAIN_FILE="$PSScriptRoot/extern/vcpkg/scripts/buildsystems/vcpkg.cmake"
& cmake --build $PSScriptRoot/build --config Release