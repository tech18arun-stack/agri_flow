# Generate Upload Keystore for Play Store
# This script creates a keystore with an upload key for signing your app

$keystorePath = "android\app\upload-keystore.jks"

if (Test-Path $keystorePath) {
    Write-Host "⚠️  Keystore already exists at: $keystorePath" -ForegroundColor Yellow
    Write-Host "   If you want to generate a new one, delete the existing file first." -ForegroundColor Yellow
    exit
}

Write-Host "🔐 Generating upload keystore for Play Store..." -ForegroundColor Cyan
Write-Host ""

# Create directory if it doesn't exist
$keystoreDir = Split-Path $keystorePath -Parent
if (-not (Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Force -Path $keystoreDir | Out-Null
}

# Find keytool executable
$keytool = $null

# Try common Java installation locations on Windows
$possiblePaths = @(
    # Android Studio JBR (JetBrains Runtime)
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "C:\Program Files (x86)\Android\Android Studio\jbr\bin\keytool.exe",
    # Android Studio old JRE
    "C:\Program Files\Android\Android Studio\jre\bin\keytool.exe",
    # Oracle JDK
    "C:\Program Files\Java\jdk*\bin\keytool.exe",
    "C:\Program Files (x86)\Java\jdk*\bin\keytool.exe",
    # OpenJDK
    "C:\Program Files\OpenJDK*\bin\keytool.exe",
    # Eclipse Temurin
    "C:\Program Files\Eclipse Adoptium\jdk*\bin\keytool.exe",
    # Microsoft JDK
    "C:\Program Files\Microsoft\jdk*\bin\keytool.exe"
)

foreach ($path in $possiblePaths) {
    # Handle wildcard paths
    if ($path -match '\*') {
        $results = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        foreach ($result in $results) {
            $fullPath = Join-Path $result.Directory.FullName "keytool.exe"
            if (Test-Path $fullPath) {
                $keytool = $fullPath
                Write-Host "✅ Found keytool at: $keytool" -ForegroundColor Green
                break
            }
        }
    } else {
        if (Test-Path $path) {
            $keytool = $path
            Write-Host "✅ Found keytool at: $keytool" -ForegroundColor Green
        }
    }
    if ($keytool) { break }
}

# If not found in common paths, try JAVA_HOME
if (-not $keytool) {
    $javaHome = $env:JAVA_HOME
    if ($javaHome) {
        $javaHomeKeytool = Join-Path $javaHome "bin\keytool.exe"
        if (Test-Path $javaHomeKeytool) {
            $keytool = $javaHomeKeytool
            Write-Host "✅ Found keytool via JAVA_HOME: $keytool" -ForegroundColor Green
        }
    }
}

# If still not found, try PATH
if (-not $keytool) {
    try {
        $pathKeytool = Get-Command "keytool.exe" -ErrorAction Stop
        $keytool = $pathKeytool.Source
        Write-Host "✅ Found keytool via PATH: $keytool" -ForegroundColor Green
    } catch {
        # keytool not in PATH
    }
}

# If still not found, ask user to locate it
if (-not $keytool) {
    Write-Host "❌ keytool not found in common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "🔍 Please locate your keytool.exe file manually." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common locations to check:" -ForegroundColor White
    Write-Host "  • Android Studio: C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -ForegroundColor White
    Write-Host "  • Oracle JDK: C:\Program Files\Java\jdk-xx\bin\keytool.exe" -ForegroundColor White
    Write-Host "  • OpenJDK: C:\Program Files\OpenJDK\jdk-xx\bin\keytool.exe" -ForegroundColor White
    Write-Host ""
    Write-Host "Or install Java JDK:" -ForegroundColor Cyan
    Write-Host "  1. Download from: https://adoptium.net/temurin/releases/" -ForegroundColor White
    Write-Host "  2. Install and restart PowerShell" -ForegroundColor White
    Write-Host "  3. Run this script again" -ForegroundColor White
    Write-Host ""
    $manualPath = Read-Host "Or paste the full path to keytool.exe (or press Enter to cancel)"
    if ($manualPath -and (Test-Path $manualPath)) {
        $keytool = $manualPath
    } else {
        Write-Host "❌ Keystore generation cancelled." -ForegroundColor Yellow
        exit 1
    }
}

# Generate keystore
$keytoolArgs = @(
    "-genkey",
    "-v",
    "-keystore", $keystorePath,
    "-alias", "upload",
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-storepass", "changeit",
    "-keypass", "changeit",
    "-dname", "CN=AgriFlow, OU=Development, O=Farm, L=City, S=State, C=IN"
)

& $keytool $keytoolArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Keystore generated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 Keystore location: $keystorePath" -ForegroundColor Cyan
    Write-Host "🔑 Alias: upload" -ForegroundColor Cyan
    Write-Host "🔒 Store/Key password: changeit" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚠️  IMPORTANT SECURITY WARNINGS:" -ForegroundColor Yellow
    Write-Host "   1. BACKUP this keystore file safely!" -ForegroundColor Yellow
    Write-Host "   2. NEVER commit the keystore to version control!" -ForegroundColor Yellow
    Write-Host "   3. Change the default passwords in android/key.properties" -ForegroundColor Yellow
    Write-Host "   4. Keep your keystore password secure - you'll need it for updates" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📝 Next steps:" -ForegroundColor Green
    Write-Host "   1. Update passwords in android/key.properties" -ForegroundColor White
    Write-Host "   2. Run: flutter build appbundle --release" -ForegroundColor White
    Write-Host "   3. Upload .aab file to Google Play Console" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Failed to generate keystore. Make sure keytool is in your PATH." -ForegroundColor Red
    Write-Host "   keytool is usually located at: C:\Program Files\Java\jdk*\bin\keytool.exe" -ForegroundColor Red
}
