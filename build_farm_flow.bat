@echo off
echo 🧹 Cleaning up hanging processes...
taskkill /F /IM java.exe /T >nul 2>&1
echo 🔐 Step 1: Generating Keystore...

powershell -ExecutionPolicy Bypass -File generate-keystore.ps1

echo.
echo 🧹 Step 2: Cleaning Flutter build...
call flutter clean

echo.
echo 📦 Step 3: Building App Bundle (Release)...
call flutter build appbundle

echo.
echo ✅ Done! Your app bundle is ready in build\app\outputs\bundle\release\
pause
