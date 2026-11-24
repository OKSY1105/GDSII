# GDSII — UART & MCU_UART RTL-to-GDSII Portfolio

Cadence EDA 툴(Xcelium, Genus, Conformal LEC, Innovus, Tempus)과 GPDK045(45nm) 교육용 라이브러리를 활용해 **직접 설계한 8E1 UART IP(`UART_GDSII`)**와 **ARM Cortex-M0 MCU의 UART2를 자작 UART로 교체 통합한 SoC(`MCU_UART`)**의 전체 RTL-to-GDSII 구현·검증 결과를 정리한 저장소입니다.

> **IP 및 라이선스 준수 정책**
> - ARM DesignStart / CMSDK 원본 RTL·제약 파일 및 Cortex-M0 파생 넷리스트(`.v`, `.sdf`), GPDK045 PDK 라이브러리(`.lib`, `.lef`, `.tch`, `.capTbl`), PDK 셀이 병합된 `.gds` 바이너리, Innovus `.dat` DB 및 서버 로그는 라이선스·보안 준수를 위해 `.gitignore`로 모두 제외했습니다.
> - 본 저장소에는 본인이 직접 설계·작성한 RTL, 테스트벤치, 합성·PnR·LEC 스크립트, SDC/MMMC 제약, 검증 리포트 중심으로 관리합니다.

---

## 전체 프로젝트 비교 및 완료 현황 (2026-11-24 기준)

| 프로젝트 | 경로 | 설계 개요 | 주요 최종 검증 결과 | 상태 |
|---|---|---|---|:---:|
| **UART 단독 칩 (`uart_pad`)** | `UART_GDSII/SoC_make_G45/TOP/` | 자작 16B FIFO · 8E1 UART + IO/전원 PAD (100 MHz, 10 ns) | Setup `+6.083 ns`, Hold `+0.001 ns`, DRC·Conn `0`, Pre/Post-LEC `356/356` PASS, Tempus SDF 2종 | ✅ 완료 |
| **UART 블록 (`uart_no_pad`)** | `UART_GDSII/SoC_make_G45/TOP/` | PAD 제외 코어 블록 (0.01 pF 부하 재합성, Removal 수정) | SS `+7.080 ns`, DRV `0`, Pre-LEC `356/356` PASS, `holdTargetSlack 0.02` 검증 완료 | ✅ 완료 |
| **8-bit CPU (`cpu8`)** | `UART_GDSII/SoC_make_G45/TOP/RTL/cpu8/` | 자작 8-bit CPU RTL 및 Genus 45nm 합성 | RTL 검증 및 Genus 45nm 합성 완료 | ✅ 완료 |
| **MCU_UART (UART2 교체 SoC)** | `MCU_UART/` | Cortex-M0 MCU의 UART2를 자작 UART + 21핀 APB Wrapper로 평면 통합 (125 MHz, 8 ns, 204 PAD) | Pre-LEC `2,621/2,621` PASS, PnR 0~5단계 DRC·Conn `0/0`, Static Power `77.47 mW`, Tempus Real Net `100%` / Setup `+0.015 ns` / Hold `+0.007 ns` / 전 항목 `0 Violated` (ECO 불필요), Post-LEC PASS, Post-SIM `max`/`min` SDF `98.26%` / 위반 `0` / `TEST Passed` | ✅ 완료 |

---

## 1. `MCU_UART` — ARM Cortex-M0 SoC UART2 교체 통합

### 1-1. 자작 RTL 및 테스트벤치 (`MCU_UART/`)
- **`cortexm0_designstart/logical/uart_apb/verilog/` (6개)**:
  - `uart_apb_wrapper.v`: CMSDK `cmsdk_apb_uart`와 21핀 포트 및 레지스터 맵(`DATA/STATE/CTRL/INTSTATUS/BAUDDIV`)이 100% 호환되는 APB Wrapper (기존 `hello.hex` 펌웨어 무수정 동작)
  - `uart_top.v`, `uart_tx.v`, `uart_rx.v`, `baud_rate_gen.v`, `fifo.v`: 자작 16B FIFO · 8E1 UART RTL 5개 무수정 재사용 (`125 MHz` / `115200 baud`, `OS_DIV = 68`, 오차 `-0.27%`)
- **`SoC_make_G45/TOP/SIM/TESTBENCH/uart_capture_8e1.v`** & **`SIM/UNIT_UART_APB/tb_uart_apb_wrapper.v`**: 8E1 프레임·짝수 패리티 검증 수신기 및 APB Wrapper 단위 테스트벤치 (`23/23 PASS`)

### 1-2. 단계별 검증 및 핵심 트러블슈팅 성과
| 단계 | 핵심 결과 | 주요 트러블슈팅 / 개선 |
|---|---|---|
| **RTL & Pre-SIM** | 단위 `23/23 PASS`, MCU `"Hello World" / "I want FPGA Job" / "** TEST Passed **"` (PE `0`, FE `0`) | 8E1 수신 모델(`uart_capture_8e1.v`) 자체 구현 |
| **1·2단 합성 & Pre-LEC** | Stage 1 Violating `0` (`15,200` leaf, `u_apb_uart_2` `1,320` cells), Pre-LEC **`2,621/2,621` PASS** | 계층 이름 통일(`mcu_uart_mapped/`) 및 `/GPDK045` 절대 경로화 |
| **PnR 0~2단계 (`PlaceOpt`)** | `optDesign` WNS **`+0.002 ns`**, Violating **`0 / 4,861`**, Density `3.681%` | 2차 합성 SDC 586행 `set_dont_touch`로 `WNS -5.189 ns` / `861` 위반 발생 → 주석 처리 및 `0→1→2` 클린 재실행으로 `0건` 해소 |
| **PnR 3~4단계 (`CTS/Route`)** | Post-Route Setup **`+0.026 ns`** (`reg2reg +0.186`), Hold **`+0.005 ns`** (`reg2reg +0.052`), `verify_drc 0`, `verifyConnectivity 0`, Power **`77.47 mW`** | `giolib045.lef` `PADVDD` Metal4 패스스루 핀 누락 규명(`-ignorePGPin` 적용 → `0 Viols`) 및 `holdTargetSlack 0.02` 선제 반영 |
| **PnR 5단계 (`ChipFinish`)** | Filler `84,454`개, `verify_drc 0`, `verifyConnectivity 0`, Die `4,030×4,030 ㎛` (204 PAD) | Pad-Limited SoC 구조 정량 분석 |
| **Tempus Sign-off STA** | Real Net **`100.00%`** (`21,252/21,252`), 전 9종 체크 **Violated `0`** (Setup `+0.015 ns`, Hold `+0.007 ns`) | 4단계 `holdTargetSlack 0.02` 선제 반영으로 **6단계 ECO 없이 1회 PASS** |
| **Post-LEC & Post-SIM** | Post-LEC PASS, `POST/max` & `POST/min` 모두 **SDF `98.26%` (`56,873/57,882`)**, 위반 `0`, **`** TEST Passed **`** | `saveNetlist -flat`과 계층형 Tempus SDF 스코프 불일치(`0.92%`) 규명 → 계층형 넷리스트로 **`98.26%`** 달성 |

---

## 2. `UART_GDSII` — 자작 8E1 UART 단독 칩(`uart_pad`) 및 블록(`uart_no_pad`)

- **자작 RTL (`UART_GDSII/SoC_make_G45/TOP/RTL/`)**: `uart_top.v`, `uart_tx.v`, `uart_rx.v`, `baud_rate_gen.v`, `fifo.v`, `cpu8/`
- **핵심 결과 (`uart_pad`, 100 MHz / 10 ns)**: 합성 `+7.080 ns` (`832 cells`, `32,651.6 ㎛²`), Pre/Post-LEC **`356/356` PASS**, PnR Post-Route Setup `+6.083 ns` / Hold `+0.001 ns`, DRC·Connectivity `0`, Tempus SDF 2종 추출 완료.
- 상세 기록은 [`UART_GDSII/README.md`](UART_GDSII/README.md)를 참고하세요.
