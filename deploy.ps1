# AgriFlow Flutter Web Direct Deployment Script (Windows)

# --- CONFIGURATION ---
$ENV_FILE = "deploy.env"

if (Test-Path $ENV_FILE) {
    echo "📄 Loading configuration from $ENV_FILE"
    Get-Content $ENV_FILE | ForEach-Object {
        if ($_ -match '^(?<name>[^=]+)=(?<value>.*)$') {
            Set-Variable -Name $Matches['name'] -Value $Matches['value']
        }
    }
    $SERVER_IP = $DEPLOY_SERVER_IP
    $SERVER_USER = $DEPLOY_SERVER_USER
    $SERVER_PORT = $DEPLOY_SERVER_PORT
    $REMOTE_PATH = $DEPLOY_REMOTE_PATH
} else {
    $SERVER_USER = "server"           # Change to your server username
    $SERVER_IP = "100.110.78.25"    # Change to your server IP
    $SERVER_PORT = "22"             # Default SSH port
    $REMOTE_PATH = "/var/www/flutter_app"
    echo "⚠️  No $ENV_FILE found. Using hardcoded configuration."
}
# ---------------------

echo "Starting Deployment Flow..."

# 1. Build Flutter Web
echo "Building Flutter Web..."
flutter build web --no-wasm-dry-run

if ($LASTEXITCODE -ne 0) {
    echo "Build failed! Aborting deployment."
    exit
}

echo "Build complete at build/web/"

# 2. Upload to Server
# Note: Using SCP as it's standard on Windows/Linux environments. 
# For faster sync, install rsync on Windows (via WSL or Cygwin).
echo "Uploading files to $SERVER_IP..."

echo "Compressing build output..."
# Using native tar to resolve the backslash directory structure corruption happening across Windows -> Linux zip extraction.
tar.exe -czf build\web.tar.gz -C build\web .

echo "syncing configuration..."
scp -P $SERVER_PORT nginx_config "${SERVER_USER}@${SERVER_IP}:${REMOTE_PATH}/nginx_config"

echo "syncing application build (zipped)..."
scp -P $SERVER_PORT build\web.tar.gz "${SERVER_USER}@${SERVER_IP}:${REMOTE_PATH}/web.tar.gz"

if ($LASTEXITCODE -ne 0) {
    echo "Upload failed! Check your connection and SSH keys."
    exit
}

echo "Extracting on server..."
ssh -p $SERVER_PORT ${SERVER_USER}@${SERVER_IP} "cd ${REMOTE_PATH} && tar -xzf web.tar.gz && rm web.tar.gz"



echo "Deployment Successful!"
echo "Access your app at: http://$SERVER_IP"
