# Generate Upload Keystore for Play Store
$keystorePath = "android\app\upload-keystore.jks"

if (Test-Path $keystorePath) {
    Write-Host "Keystore already exists at: $keystorePath"
    exit
}

Write-Host "Generating upload keystore for Play Store..."

# Find keytool executable
$keytool = "keytool.exe" # Assume it is in PATH by default

# Try common paths if not in PATH
$possiblePaths = @(
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "C:\Program Files\Java\jdk*\bin\keytool.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $keytool = $path
        break
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
    "-dname", "CN=FarmFlow, OU=Development, O=Farm, L=City, S=State, C=IN"
)

Write-Host "Running: $keytool $($keytoolArgs -join ' ')"
& $keytool $keytoolArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "Keystore generated successfully at $keystorePath"
} else {
    Write-Host "Failed to generate keystore. Please ensure Java/keytool is installed."
}
