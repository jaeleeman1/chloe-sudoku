# Chloe Sudoku Design & Technical Specification

## 1. 개요 (Objective)
Flutter를 사용하여 사용자가 표준 9x9 스도쿠 퍼즐을 즐길 수 있는 모던하고 직관적인 애플리케이션을 구현합니다. 난이도 선택, 시작/경과 시간 측정, 직관적인 3단계 선 스타일링 및 상하좌우 셀 강조 기능을 제공합니다.

---

## 2. 주요 기능 및 UI/UX 사양 (Key Features & UI/UX)

### 2.1 상단 컨트롤 & 정보 바
- **New Game 버튼**: 앱바 상단 우측에 `+ New Game` 아웃라인 버튼 배치. 클릭 시 타이머 초기화 및 선택된 난이도의 새 퍼즐 시작.
- **난이도 선택 (Difficulty Selection)**:
  - 정보 바 좌측에 드롭다운 메뉴 (`초급 ▾`, `중급`, `고급`) 제공.
  - **초급 (Easy)**: 빈칸 30개
  - **중급 (Medium)**: 빈칸 42개
  - **고급 (Hard)**: 빈칸 52개
  - 난이도 변경 시 해당 난이도로 새 게임 자동 시작.
- **시간 측정 (Timer)**:
  - **시작 시간**: 해당 퍼즐을 시작한 시각 (`HH:mm:ss`) 표시.
  - **경과 시간**: 1초 단위 실시간 스톱워치 (`mm:ss` / `hh:mm:ss`). 퍼즐 완료 시 타이머 멈춤 및 축하 팝업 출력.

### 2.2 스도쿠 격자 및 선 스타일 (Grid Line Hierarchy)
- **9×9 최외곽 프레임**: `2.0px` 두께의 검은색 (`Colors.black`) 외곽선.
- **3×3 블록 구분선**: `1.0px` 두께의 중간 회색 (`Colors.grey[600]`) 구분선으로 3x3 블록을 눈이 편하게 구분.
- **3×3 내부 셀 간의 선**: `0.5px` 두께의 연한 회색 (`Colors.grey[300]`) 미세선.

### 2.3 상호작용 및 시각적 피드백 (Visual Highlights)
- **선택 셀 강조**: 터치된 셀은 파란색 (`Colors.blue[200]`) 배경 강조.
- **상하좌우(행/열) 및 동일 숫자 강조**:
  - 선택한 셀 기준 **가로(좌우 행) 및 세로(위아래 열)** 전체 연푸른색 (`Colors.blue[50]`) 강조.
  - 선택한 셀에 숫자가 있는 경우, 판 전체에서 **동일한 숫자가 들어간 셀들**도 연푸른색 배경으로 함께 하이라이트.
- **실시간 유효성 검사**: 중복/규칙 위반 입력 시 숫자 빨간색 처리.

---

## 3. 검증된 개발 환경 및 빌드 사양 (Verified Build Environment)
- **Flutter SDK**: `3.47.2` (stable, `C:\sdk\flutter`)
- **Dart SDK**: `3.13.2`
- **Gradle**: `8.7` (`gradle-8.7-all.zip`)
- **Android Gradle Plugin (AGP)**: `8.7.3`
- **Kotlin**: `2.0.21`

---

## 4. 아키텍처 및 파일 구조 (Project Architecture)
- `lib/main.dart`: 앱 진입점 및 Material 3 테마 설정.
- `lib/models/sudoku_grid.dart`: 81개 셀의 고정 여부, 사용자 입력값, 유효성 상태 관리 모델.
- `lib/logic/sudoku_engine.dart`: 난이도별 퍼즐 생성, 백트래킹 퍼즐 풀이 및 유효성 검증 엔진.
- `lib/widgets/sudoku_cell.dart`: 3단계 선 스타일링 및 강조 배경이 적용된 개별 셀 위젯.
- `lib/widgets/number_pad.dart`: 1~9 숫자 입력 및 삭제 키패드 위젯.
- `lib/screens/home_screen.dart`: 난이도 선택, 시작/경과 시간 타이머, 게임 로직 및 메인 UI 화면.

---

## 5. 변경 이력 (Changelog)
- **v1.1.0** (2026-09-02):
  - `+ New Game` 버튼 추가.
  - 난이도 선택(초급/중급/고급) 기능 구현.
  - 시작 시각 및 경과 시간 실시간 타이머 구현.
  - 격자 선 3단계 계층화 (최외곽 2.0px, 3x3 구분선 1.0px grey[600], 내부선 0.5px grey[300]).
  - 터치 지점 상하좌우(행/열) 및 동일 숫자 연푸른색 강조 피드백 추가.
  - 검증된 안정 빌드 사양 (Gradle 8.7 / AGP 8.7.3) 문서화.
