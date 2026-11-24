# GDSII — UART & MCU_UART RTL-to-GDSII 포트폴리오

Cadence EDA 툴체인(Xcelium, Genus, Conformal LEC, Innovus, Tempus)과 GPDK045(45nm) 교육용 라이브러리를 기반으로 **자작 8E1 UART IP(`UART_GDSII`)**와 **ARM Cortex-M0 MCU의 UART2를 자작 UART로 교체·통합한 SoC(`MCU_UART`)**의 전체 RTL-to-GDSII 구현 및 Sign-off 검증 결과를 정리한 저장소다.

> **IP 및 라이선스 준수 정책**
> - ARM DesignStart / CMSDK 원본 RTL·제약 파일 및 Cortex-M0 파생 넷리스트(`.v`, `.sdf`), GPDK045 PDK 라이브러리(`.lib`, `.lef`, `.tch`, `.capTbl`), PDK 셀이 병합된 `.gds` 바이너리, Innovus `.dat` DB 및 서버 로그는 라이선스·보안 준수를 위해 `.gitignore`로 일괄 제외한다.
> - 본 저장소에는 직접 설계·작성한 RTL, 테스트벤치, 합성·PnR·LEC 스크립트, SDC/MMMC 제약, 검증 리포트 및 단계별 검증 캡처 이미지만 관리한다.

---

## 프로젝트 완료 현황 (2026-11-24 기준)

| 프로젝트 | 경로 | 설계 개요 | 최종 검증 결과 | 상태 |
|---|---|---|---|:---:|
| **UART 단독 칩 (`uart_pad`)** | [`UART_GDSII/`](UART_GDSII/README.md) | 자작 16B FIFO · 8E1 UART + 46 PAD (`100 MHz`, `10 ns`, Die `1,748×1,748 ㎛`) | Setup `+6.103 ns`, Hold `+0.003 ns`, DRC·Conn `0/0`, Pre/Post-LEC `356/356` PASS, Tempus Real Net `100%` · 전 항목 `0 Violated` | 완료 |
| **UART 코어 블록 (`uart_no_pad`)** | [`UART_GDSII/`](UART_GDSII/README.md) | PAD 제외 내부 블록 (`0.01 pF` 부하 재합성, `100 MHz`, `10 ns`) | SS `+7.080 ns`, Post-Route Setup `+7.769 ns` / Hold `+0.013 ns`, DRV `0`, Pre/Post-LEC `356/356` PASS, Tempus Removal `5 → 0 Violated` | 완료 |
| **8-bit CPU (`cpu8`)** | [`UART_GDSII/SoC_make_G45/TOP/RTL/`](UART_GDSII/SoC_make_G45/TOP/RTL/README.md) | 자작 8-bit CPU RTL 및 Genus 45nm 합성 | RTL 기능 검증 및 Genus 45nm 합성 완료 | 완료 |
| **MCU_UART (UART2 교체 SoC)** | [`MCU_UART/`](MCU_UART/README.md) | Cortex-M0 MCU의 UART2를 자작 UART + 21핀 APB Wrapper로 평면 통합 (`125 MHz`, `8 ns`, 204 PAD, Die `4,030×4,030 ㎛`) | Pre-LEC `2,621/2,621` PASS, PnR 0~5단계 DRC·Conn `0/0`, Static Power `77.47 mW`, Tempus Real Net `100%` / Setup `+0.015 ns` / Hold `+0.007 ns` / 전 항목 `0 Violated` (ECO 불필요), Post-LEC `2,621/2,621` PASS, Post-SIM `max`/`min` SDF `98.26%` · 위반 `0` · `TEST Passed` | 완료 |

---

## 폴더별 상세 문서 바로가기

### 1. `MCU_UART` — ARM Cortex-M0 SoC UART2 교체 통합

| 단계 / 영역 | 문서 링크 | 주요 내용 및 포함 캡처 |
|---|---|---|
| 프로젝트 개요 | [`MCU_UART/README.md`](MCU_UART/README.md) | Plan B 평면 통합 구조, 전체 흐름 요약 및 트러블슈팅 총괄 |
| 자작 RTL (APB Wrapper + UART) | [`MCU_UART/cortexm0_designstart/logical/uart_apb/README.md`](MCU_UART/cortexm0_designstart/logical/uart_apb/README.md) | 21핀 포트 호환성, APB 레지스터 맵(`0x000`~`0x010`), 125 MHz 보레이트 설계 |
| 시뮬레이션 (UNIT / FUNC / PRE / POST) | [`MCU_UART/SoC_make_G45/TOP/SIM/README.md`](MCU_UART/SoC_make_G45/TOP/SIM/README.md) | Pre-SIM, Post-SIM `max`/`min` 파형·로그 및 SDF `0.92% → 98.26%` 해결 과정 |
| 논리 합성 (Genus 45nm, 2단계) | [`MCU_UART/SoC_make_G45/TOP/SYN/README.md`](MCU_UART/SoC_make_G45/TOP/SYN/README.md) | `cmsdk_mcu_system` → `cmsdk_mcu` 2단 합성, QoR·면적·전력 및 SDC `dont_touch` 분석 |
| 등가성 검증 (Conformal Pre/Post-LEC) | [`MCU_UART/SoC_make_G45/TOP/EC/README.md`](MCU_UART/SoC_make_G45/TOP/EC/README.md) | Pre-LEC `2,621/2,621` PASS 및 Post-LEC `2,621/2,621` PASS 캡처 6종 |
| PnR & Sign-off STA (Innovus / Tempus) | [`MCU_UART/SoC_make_G45/TOP/PNR/README.md`](MCU_UART/SoC_make_G45/TOP/PNR/README.md) | 0~5단계 레이아웃·리포트, Before/After 트러블슈팅, Tempus 회로도·STA 요약 15종 |

### 2. `UART_GDSII` — 자작 8E1 UART 단독 칩(`uart_pad`) 및 코어 블록(`uart_no_pad`)

| 단계 / 영역 | 문서 링크 | 주요 내용 및 포함 캡처 |
|---|---|---|
| 프로젝트 개요 | [`UART_GDSII/README.md`](UART_GDSII/README.md) | `uart_pad` 및 `uart_no_pad` 전체 설계·검증 완료 요약 |
| 자작 RTL (UART + CPU8) | [`UART_GDSII/SoC_make_G45/TOP/RTL/README.md`](UART_GDSII/SoC_make_G45/TOP/RTL/README.md) | 5개 UART 모듈 구조, `USE_IO_PAD` 매크로 분기, 8E1·16B FIFO 규격 및 `cpu8` 개요 |
| 시뮬레이션 (FUNCTION / PRE) | [`UART_GDSII/SoC_make_G45/TOP/SIM/README.md`](UART_GDSII/SoC_make_G45/TOP/SIM/README.md) | `uart_pad` / `uart_no_pad` 28바이트 ASCII 에코 검증 파형 및 로그 4종 |
| 논리 합성 (Genus 45nm MMMC) | [`UART_GDSII/SoC_make_G45/TOP/SYN/README.md`](UART_GDSII/SoC_make_G45/TOP/SYN/README.md) | `uart_pad`(`1.0 pF`) vs `uart_no_pad`(`0.01 pF`) MMMC 합성 비교 및 QoR 수치 |
| 등가성 검증 (Conformal Pre/Post-LEC) | [`UART_GDSII/SoC_make_G45/TOP/EC/README.md`](UART_GDSII/SoC_make_G45/TOP/EC/README.md) | `uart_pad` / `uart_no_pad` Pre·Post-LEC `356/356` PASS 캡처 13종 |
| PnR & Sign-off STA (Innovus / Tempus) | [`UART_GDSII/SoC_make_G45/TOP/PNR/README.md`](UART_GDSII/SoC_make_G45/TOP/PNR/README.md) | `uart_pad` 및 `uart_no_pad` 0~5단계 레이아웃·타이밍·SVG 차트·Tempus 캡처 33종 |

---

## 사용 환경 및 툴체인

- **Process / PDK**: Cadence GPDK045 (`45 nm` SVT standard cell `gsclib045_v4.4`, IO library `giolib045_v3.5`, QRC techfile)
- **Simulation**: Cadence Xcelium 22.03 (`xrun`, SimVision)
- **Synthesis**: Cadence Genus 22.17 (MMMC / 45 nm)
- **Equivalence Checking**: Cadence Conformal LEC
- **Place & Route**: Cadence Innovus (Legacy Tcl flow, 0~5단계 + ECO)
- **Sign-off STA**: Cadence Tempus (SPEF/RCDB 기반 Worst/Best SDF 추출)
