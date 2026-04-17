# Build AgriFlow for Play Store Release
# This script builds the signed Android App Bundle (.aab) for Play Store

Write-Host "🚀 Building AgriFlow for Play Store..." -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: pubspec.yaml not found. Run this from the project root." -ForegroundColor Red
    exit 1
}

# Check if keystore exists
$keystorePath = "android\app\upload-keystore.jks"
if (-not (Test-Path $keystorePath)) {
    Write-Host "⚠️  Keystore not found at: $keystorePath" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Would you like to generate it now? (y/n)"
    if ($response -eq "y" -or $response -eq "yes") {
        & .\generate-keystore.ps1
        if (-not (Test-Path $keystorePath)) {
            Write-Host "❌ Keystore generation failed. Cannot continue." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Keystore is required for building. Please run generate-keystore.ps1 first." -ForegroundColor Red
        exit 1
    }
}

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Clean failed" -ForegroundColor Red
    exit 1
}

# Get dependencies
Write-Host ""
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies" -ForegroundColor Red
    exit 1
}

# Generate launcher icons if needed
Write-Host ""
Write-Host "🎨 Generating launcher icons..." -ForegroundColor Yellow
flutter pub run flutter_launcher_icons
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Failed to generate launcher icons (non-critical)" -ForegroundColor Yellow
}

# Build the app bundle
Write-Host ""
Write-Host "🔨 Building Android App Bundle (.aab)..." -ForegroundColor Cyan
Write-Host ""

flutter build appbundle --release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Build failed. Check the errors above." -ForegroundColor Red
    exit 1
}

# Find the output file
$buildOutput = "build\app\outputs\bundle\release"
if (Test-Path $buildOutput) {
    $aabFile = Get-ChildItem -Path $buildOutput -Filter "*.aab" | Select-Object -First 1
    
    if ($aabFile) {
        $fileSize = [math]::Round($aabFile.Length / 1MB, 2)
        
        Write-Host ""
        Write-Host "✅ Build successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📁 Output: $($aabFile.FullName)" -ForegroundColor Cyan
        Write-Host "📊 Size: $fileSize MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🎯 Next Steps for Play Store:" -ForegroundColor Green
        Write-Host "   1. Go to https://play.google.com/console" -ForegroundColor White
        Write-Host "   2. Select your app or create a new one" -ForegroundColor White
        Write-Host "   3. Go to 'Production' or 'Internal testing'" -ForegroundColor White
        Write-Host "   4. Click 'Create new release'" -ForegroundColor White
        Write-Host "   5. Upload the .aab file: $($aabFile.Name)" -ForegroundColor White
        Write-Host "   6. Fill in release notes and submit" -ForegroundColor White
        Write-Host ""
        Write-Host "📝 Store Listing Requirements:" -ForegroundColor Yellow
        Write-Host "   ✓ App name: AgriFlow" -ForegroundColor White
        Write-Host "   ✓ Short description (80 chars)" -ForegroundColor White
        Write-Host "   ✓ Full description (4000 chars)" -ForegroundColor White
        Write-Host "   ✓ Screenshots (phone: 2-8, tablet: 2-8)" -ForegroundColor White
        Write-Host "   ✓ App icon (512x512 PNG)" -ForegroundColor White
        Write-Host "   ✓ Feature graphic (1024x500 PNG)" -ForegroundColor White
        Write-Host "   ✓ Privacy policy URL" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠️  Important:" -ForegroundColor Red
        Write-Host "   - Keep your keystore file SAFE and BACKUP everywhere!" -ForegroundColor White
        Write-Host "   - You NEED the same keystore for all future updates" -ForegroundColor White
        Write-Host "   - Without it, you CANNOT update your app on Play Store" -ForegroundColor White
    } else {
        Write-Host "⚠️  Build completed but .aab file not found in $buildOutput" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Build output directory not found: $buildOutput" -ForegroundColor Yellow
}
