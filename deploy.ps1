[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🚀 Chloe Sudoku 자동 배포 시작..." -ForegroundColor Cyan

# 1. Flutter Web 빌드 (--no-tree-shake-icons 옵션 적용)
$env:Path += ";C:\sdk\flutter\bin"
flutter pub get
flutter build web --base-href "/sudoku/" --no-tree-shake-icons

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter Web 빌드 실패" -ForegroundColor Red
    exit 1
}

# 2. N100 미니 PC로 빌드 결과물 전송
Write-Host "📦 N100 미니 PC로 파일 전송 중 (/home/felix530/project/sudoku-web)..." -ForegroundColor Yellow
scp -r build/web/* felix530@192.168.35.137:/home/felix530/project/sudoku-web/

# 3. N100 Docker 컨테이너 재시작
Write-Host "🔄 N100 Docker 컨테이너 재시작 중..." -ForegroundColor Green
ssh felix530@192.168.35.137 "docker restart chloe-sudoku"

Write-Host "🎉 배포 성공! 접속 주소: https://love-soobin.duckdns.org/sudoku/" -ForegroundColor Green
