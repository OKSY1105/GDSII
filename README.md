# GDSII — UART & MCU_UART RTL-to-GDSII Portfolio

Cadence EDA 툴(Xcelium, Genus, Conformal LEC, Innovus, Tempus)과 GPDK045(45nm) 교육용 라이브러리를 활용해 **직접 설계한 8E1 UART IP(`UART_GDSII`)**와 **ARM Cortex-M0 MCU의 UART2를 자작 UART로 교체 통합한 SoC(`MCU_UART`)**의 RTL-to-GDSII 구현·검증 결과를 정리한 저장소입니다.

> **IP 및 라이선스 준수 정책**
> - ARM DesignStart / CMSDK 원본 RTL·제약 파일 및 Cortex-M0 파생 넷리스트, GPDK045 PDK 라이브러리(`.lib`, `.lef`, `.tch`, `.capTbl`), PDK 셀이 병합된 `.gds` 바이너리, Innovus `.dat` DB 및 서버 로그는 라이선스·보안 준수를 위해 `.gitignore`로 모두 제외했습니다.
> - 본 저장소에는 본인이 직접 설계·작성한 RTL, 테스트벤치, 합성·PnR·LEC 스크립트, SDC 제약, 검증 리포트 중심으로 관리합니다.

---

## 프로젝트 구성 및 진행 현황 (2026-11-24 기준)

| 프로젝트 | 경로 | 설계 개요 | 주요 검증 결과 | 상태 |
|---|---|---|---|:---:|
| **UART 단독 칩 (`uart_pad`)** | `UART_GDSII/SoC_make_G45/TOP/` | 자작 16B FIFO · 8E1 UART + IO/전원 PAD (100 MHz, 10 ns) | Setup `+6.083 ns`, Hold `+0.001 ns`, DRC·Connectivity `0`, Pre/Post-LEC `356/356` PASS, Tempus SDF 2종 | ✅ 완료·업로드 |
| **UART 블록 (`uart_no_pad`)** | `UART_GDSII/SoC_make_G45/TOP/` | PAD 제외 코어 블록 (0.01 pF 부하 재합성, Removal 수정) | SS `+7.080 ns`, DRV `0`, Pre-LEC `356/356` PASS, `holdTargetSlack 0.02` 검증 완료 | ✅ 업로드 |
| **8-bit CPU (`cpu8`)** | `UART_GDSII/SoC_make_G45/TOP/RTL/cpu8/` | 자작 8-bit CPU RTL 및 Genus 합성 실습 | RTL 검증 및 Genus 45nm 합성 완료 | ✅ 업로드 |
| **MCU_UART (UART2 교체 SoC)** | *(PnR 4~5단계·Post-SIM 완료 후 자작 코드·문서 업로드 예정)* | Cortex-M0 MCU의 UART2를 자작 UART + 21핀 APB Wrapper로 평면 통합 (125 MHz, 8 ns) | 단위 23/23 PASS, RTL·Pre-SIM `TEST Passed`, 1·2단 합성 Violating `0`, Pre-LEC `2,621/2,621` PASS, PnR 0~3단계 완료 (`reg2reg` Setup `+0.003 ns` / Hold `+0.052 ns`, Skew `0.132 ns`) | 🔄 PnR 4단계 진행 중 |

---

## `UART_GDSII` 주요 설계 사양 및 디렉터리 구조

### 1. 자작 UART RTL (`UART_GDSII/SoC_make_G45/TOP/RTL/`)
- `uart_top.v`: 최상위 통합 모듈 (`USE_IO_PAD` 매크로로 PAD 포함 단독 칩 / 코어 블록 분기 지원)
- `baud_rate_gen.v`: 16× 오버샘플링 보드율 분주기 (`115200 baud` 기준)
- `uart_tx.v` / `uart_rx.v`: 8-bit 데이터 + 짝수 패리티(Even Parity) + 1 Stop bit (**8E1**) 송수신기 및 패리티/프레임 에러 검출
- `fifo.v`: 16-byte TX/RX FIFO

### 2. 디렉터리 구성
```text
UART_GDSII/
├── README.md                          # UART 단독 칩·블록 상세 설계 및 PnR/LEC 기록
└── SoC_make_G45/TOP/
    ├── RTL/                           # 자작 UART RTL 5개 + cpu8 RTL 5개
    ├── SIM/                           # Xcelium RTL / Pre / Post 시뮬레이션 스크립트 및 TB
    ├── SYN/                           # Genus 45nm MMMC 합성 스크립트, SDC 제약, QoR/Area/Timing 리포트
    ├── EC/                            # Conformal LEC 스크립트 (Pre/Post 등가성 검증)
    └── PNR/                           # Innovus 0~5단계 스크립트, IO 배치, 타이밍/DRC/전력 리포트
```

### 3. `UART_GDSII` 핵심 검증 지표 (`uart_pad` 기준)
- **합성 (Genus, 100 MHz / 10 ns)**: `UART_SS_WORST` `+7.080 ns` / `UART_FF_BEST` `+9.296 ns`, Violating `0`, `832 cells` (`32,651.6 ㎛²`)
- **Pre-Layout LEC (Conformal)**: Golden vs Revised **`356 / 356` Equivalent PASS** (PI 13, PO 17, DFF 339)
- **Auto PnR (Innovus 0~5단계)**: Post-Route Setup `+6.083 ns`, Hold `+0.001 ns`, DRC `0`, Connectivity `0`
- **Post-Layout LEC & Tempus STA**: **`356 / 356` PASS**, worst/best SDF 2종 추출 완료

---

## 참고
- 상세 `UART_GDSII` 단계별 기록은 [`UART_GDSII/README.md`](UART_GDSII/README.md)를 참고하세요.
- `MCU_UART` 프로젝트의 자작 APB Wrapper(`uart_apb/`) 및 최종 검증 리포트는 PnR 4~5단계·Tempus STA·Post-Layout SIM 완료 후 저작권 안전 검증을 거쳐 추가될 예정입니다.
