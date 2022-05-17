$AF_VERSION = Read-Host -Prompt "Build Version"
Write-Output "Building into 'build\$AF_VERSION\windows\"
Remove-Item -Recurse -Force "build\$AF_VERSION\windows\" -ea 0
New-Item "build\$AF_VERSION\windows\" -ItemType Directory -ea 0
Set-Location src\anime_finder
flutter build windows --release
Set-Location ..\..
Compress-Archive -Path "src\anime_finder\build\windows\runner\Release\" -DestinationPath "build\$AF_VERSION\windows\AnimeFinder_${AF_VERSION}_Windows_x64.zip"
Write-Output "Built into 'build\$AF_VERSION\windows\"