param([Parameter(Mandatory=$true)][string]$problem)
# git writes progress to stderr; keep 'Continue' so it is not treated as a fatal error
$ErrorActionPreference = 'Continue'
$src = Join-Path $PSScriptRoot "$problem.py"
if (-not (Test-Path $src)) { Write-Host "HATA: $problem.py bulunamadi. Once dosyayi kaydet (Ctrl+S)." -ForegroundColor Red; exit 1 }
$url = 'https://github.com/me50/aydnomer.git'
$branch = "cs50/problems/2022/python/$problem"
$root = Join-Path $env:TEMP 'cs50submit'
$tmp = Join-Path $root $problem
if (Test-Path $root) { Remove-Item $root -Recurse -Force }
New-Item -ItemType Directory -Path $root | Out-Null
$exists = git ls-remote --heads $url $branch
if ($LASTEXITCODE -ne 0) { Write-Host "HATA: GitHub'a baglanilamadi." -ForegroundColor Red; Remove-Item $root -Recurse -Force; exit 1 }
if ($exists) {
    git clone -q --branch $branch $url $tmp
    if ($LASTEXITCODE -ne 0) { Write-Host "HATA: klonlanamadi." -ForegroundColor Red; Remove-Item $root -Recurse -Force; exit 1 }
} else {
    New-Item -ItemType Directory -Path $tmp | Out-Null
    git -C $tmp init -q
    git -C $tmp checkout -q -b $branch
}
Copy-Item $src $tmp -Force
git -C $tmp add -A
git -C $tmp commit -q -m "Submit $problem" | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "Degisiklik yok, zaten gonderilmis." -ForegroundColor Yellow; Remove-Item $root -Recurse -Force; exit 0 }
git -C $tmp push -q $url $branch
if ($LASTEXITCODE -eq 0) { Write-Host "GONDERILDI: $problem. Notun birkac dakika icinde: https://cs50.me/cs50p" -ForegroundColor Green } else { Write-Host "HATA: gonderilemedi." -ForegroundColor Red }
Remove-Item $root -Recurse -Force
