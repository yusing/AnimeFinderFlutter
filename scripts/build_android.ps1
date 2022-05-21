$AF_VERSION = Read-Host -Prompt "Build Version"
New-Item -Type Directory -Path build/$AF_VERSION/android
Set-Location src/anime_finder
flutter build apk --release
Set-Location ../..
Move-Item src/anime_finder/build/app/outputs/flutter-apk/app-release.apk build/$AF_VERSION/android/AnimeFinder_${AF_VERSION}_android.apk
Write-Output "Build Complete for android"