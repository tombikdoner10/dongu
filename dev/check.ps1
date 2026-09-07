# Tek komutla dogrulama: flutter analyze + flutter test.
# Cikti bilerek kirpilir; amac tek bakista "yesil mi degil mi" gormek.
#   kullanim:  pwsh dev/check.ps1   ya da   powershell -File dev\check.ps1

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "== analyze ==" -ForegroundColor Cyan
$analyze = (& flutter analyze 2>&1 | Out-String)
if ($analyze -match "No issues found") {
    Write-Host "temiz" -ForegroundColor Green
} else {
    $analyze -split "`n" |
        Where-Object { $_ -match "^\s+(info|warning|error)" } |
        Select-Object -First 20 |
        ForEach-Object { Write-Host $_ }
}

Write-Host "== test ==" -ForegroundColor Cyan
$test = (& flutter test 2>&1 | Out-String)
$lines = $test -split "`n"

$summary = $lines | Where-Object { $_ -match "All tests passed|Some tests failed" } | Select-Object -Last 1
if ($summary -match "All tests passed") {
    $count = ($lines | Where-Object { $_ -match "\+\d+" } | Select-Object -Last 1)
    Write-Host ("gecti  " + $count.Trim()) -ForegroundColor Green
} else {
    $lines |
        Where-Object { $_ -match "\[E\]|Expected:|Actual:|^\s{2}\S.*(seviye|cozum|kestirme|reason)" } |
        Select-Object -First 30 |
        ForEach-Object { Write-Host $_ -ForegroundColor Red }
    Write-Host $summary -ForegroundColor Red
}
