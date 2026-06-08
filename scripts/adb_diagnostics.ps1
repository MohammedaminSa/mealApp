Param(
    [string]$ApkPath = "build\app\outputs\flutter-apk\app-debug.apk",
    [string]$PackageName = ""
)

$timestamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$baseLogDir = Join-Path -Path (Get-Location) -ChildPath "adb_diagnostics_logs"
$logDir = Join-Path -Path $baseLogDir -ChildPath $timestamp
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Save-Text($text, $file){
    $filePath = Join-Path $logDir $file
    $text | Out-File -FilePath $filePath -Encoding utf8
}

function Run-Exe($exe, $args){
    $startInfo = "$exe $args"
    Write-Host "Running: $startInfo"
    try{
        $proc = Start-Process -FilePath $exe -ArgumentList $args -NoNewWindow -RedirectStandardOutput (Join-Path $logDir "stdout.txt") -RedirectStandardError (Join-Path $logDir "stderr.txt") -PassThru -Wait
        return $proc.ExitCode
    }catch{
        $_ | Out-String | Save-Text -File "error_exception.txt"
        return -1
    }
}

# 1) adb version
Write-Host "== adb version =="
& adb version 2>&1 | Tee-Object -Variable _adbver | Out-Null
$_adbver | Save-Text -File "adb_version.txt"

# 2) list devices
Write-Host "== adb devices -l =="
$devList = & adb devices -l 2>&1
$devList | Save-Text -File "adb_devices.txt"
Write-Host $devList

# pick first device id if any
$deviceId = $null
foreach($line in $devList){
    if($line -match "^([^\s]+)\s+device(\s|$)"){
        $deviceId = $Matches[1]
        break
    }
}

if(-not $deviceId){
    Write-Host "No device in 'device' state found. Stopping. Check emulator or USB connection."
    exit 2
}

Save-Text "Selected device: $deviceId" "selected_device.txt"

# 3) restart adb server
Write-Host "== Restarting ADB server =="
& adb kill-server 2>&1 | Out-Null
Start-Sleep -Seconds 1
& adb start-server 2>&1 | Out-Null
& adb devices -l 2>&1 | Save-Text -File "adb_devices_after_restart.txt"

# 4) basic device info
Write-Host "== Device info =="
& adb -s $deviceId shell getprop ro.product.model 2>&1 | Save-Text -File "device_model.txt"
& adb -s $deviceId shell getprop ro.build.version.release 2>&1 | Save-Text -File "device_android_version.txt"
& adb -s $deviceId shell df /data 2>&1 | Save-Text -File "device_df_data.txt"

# 5) attempt install if APK present
$apkFull = Join-Path (Get-Location) $ApkPath
if(Test-Path $apkFull){
    Write-Host "Found APK at $apkFull. Attempting install (will append install output to logs)."
    & adb -s $deviceId install -r -d "$apkFull" *> "$(Join-Path $logDir 'adb_install_output.txt')" 2>&1
}else{
    Write-Host "APK not found at $apkFull. Skipping install step."
    Save-Text "APK not found: $apkFull" "apk_missing.txt"
}

# 6) capture logcat (recent)
Write-Host "== Capturing logcat (last 1000 lines) =="
& adb -s $deviceId logcat -d -t 1000 2>&1 | Save-Text -File "adb_logcat_recent.txt"

# 7) if package name provided, try uninstall then install
if($PackageName -ne ""){
    Write-Host "== Uninstalling package $PackageName if present =="
    & adb -s $deviceId uninstall $PackageName 2>&1 | Save-Text -File "adb_uninstall_output.txt"
    if(Test-Path $apkFull){
        Write-Host "== Re-attempting install of APK =="
        & adb -s $deviceId install -r -d "$apkFull" 2>&1 | Save-Text -File "adb_install_after_uninstall.txt"
    }
}

Write-Host "Diagnostics saved to: $logDir"
Write-Host "Please paste the contents of the files in that folder here (or attach them)."

exit 0
