[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🚀 [AI Harness] Qwen3 30B Flutter 검증 및 배포 파이프라인 시작..." -ForegroundColor Cyan

# 1. Flutter 정적 코드 분석
Write-Host "🔍 1. Flutter 정적 코드 분석 중 (flutter analyze)..." -ForegroundColor Yellow
$env:Path += ";C:\sdk\flutter\bin"
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 코드 분석 실패! AI가 작성한 코드의 린터 에러를 수정하세요." -ForegroundColor Red
    exit 1
}

# 2. Web 빌드 및 N100 Docker 배포 (deploy.ps1 호출)
Write-Host "📦 2. Flutter Web 빌드 및 N100 Docker 배포 시작..." -ForegroundColor Yellow
.\deploy.ps1

Write-Host "🎉 [Harness 완료] 서비스 접속 주소: https://love-soobin.duckdns.org/sudoku/" -ForegroundColor Green
